import 'package:serverpod/serverpod.dart';
import '../../ai/providers.dart';
import '../../ai/text_template.dart';
import '../../generated/protocol.dart';
import '../../matching/candidate_query.dart';
import '../../matching/match_service.dart';
import '../../matching/scorer.dart';
import '../job_handler.dart';

class MatchReportHandler extends JobHandler {
  @override
  String get kind => 'match_report';
  @override
  Future<void> run(Session session, WorkItem job) async {
    final s = session;
    var report = await LostReport.db.findById(s, job.payload.entityId!);
    if (report == null ||
        report.venueId != job.venueId ||
        !CandidateQuery.openReports.contains(report.status) ||
        !await JobClaim.current(s, job)) {
      return;
    }
    final createdAt = report.createdAt;
    final reference = report.refCode;
    final phaseTimer = Stopwatch()..start();
    if (report.attributes == null) {
      final zone = report.zoneId == null
          ? null
          : await Zone.db.findById(s, report.zoneId!);
      final result = await Providers.normaliser.normalise(
        report.rawText,
        ReportHints(
          categoryHint: report.categoryHint,
          colourHints: report.colourHints,
          brandHint: report.brandHint,
          zoneName: zone?.name,
          whereText: report.whereText,
        ),
      );
      if (result.attributes == null) {
        throw StateError('Normalisation returned no attributes');
      }
      s.log(
        'Report normalisation ${result.outcome} in ${result.attempts.fold<int>(0, (total, attempt) => total + attempt.latencyMs)} ms',
      );
      final snapshot = report;
      report = await s.db.transaction<LostReport?>((tx) async {
        final current = await LostReport.db.findById(
          s,
          snapshot.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (current == null ||
            !CandidateQuery.openReports.contains(current.status) ||
            !await JobClaim.current(s, job, transaction: tx, lock: true)) {
          return null;
        }
        if (current.attributes != null) return current;
        final updated = await LostReport.db.updateRow(
          s,
          current.copyWith(
            attributes: protectAttributes(result.attributes!),
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        );
        for (final attempt in result.attempts) {
          await AuditEvent.db.insertRow(
            s,
            AuditEvent(
              venueId: current.venueId,
              entityType: 'report',
              entityId: current.id!,
              action: 'normalised',
              payload: AuditPayload(
                summary: 'Report normalised',
                data: {
                  'provider': attempt.provider,
                  'outcome': attempt.outcome,
                  'latencyMs': attempt.latencyMs.toString(),
                  'model': attempt.modelId,
                  'itemCount': result.itemCount.toString(),
                },
              ),
            ),
            transaction: tx,
          );
        }
        return updated;
      });
      if (report == null) return;
    }
    final normalisationMs = phaseTimer.elapsedMilliseconds;
    phaseTimer.reset();
    if (report.embedding == null) {
      final embeddingTimer = Stopwatch()..start();
      final values = await Providers.embedder.embedQuery(
        TextTemplate.render(report.attributes!),
      );
      s.log(
        'Report query embedding completed in ${embeddingTimer.elapsedMilliseconds} ms',
      );
      if (values.length != 1536 || values.any((v) => !v.isFinite)) {
        throw const FormatException('Invalid report embedding');
      }
      final snapshot = report;
      report = await s.db.transaction<LostReport?>((tx) async {
        final current = await LostReport.db.findById(
          s,
          snapshot.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (current == null ||
            !CandidateQuery.openReports.contains(current.status) ||
            !await JobClaim.current(s, job, transaction: tx, lock: true)) {
          return null;
        }
        if (current.embedding != null) return current;
        return LostReport.db.updateRow(
          s,
          current.copyWith(
            embedding: Vector(values),
            embeddingModel: Providers.embedder.modelId,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        );
      });
      if (report == null) return;
    }
    final embeddingMs = phaseTimer.elapsedMilliseconds;
    phaseTimer.reset();
    final rows = await CandidateQuery().forReport(s, report);
    await MatchService().apply(
      s,
      job,
      report,
      rows.map(const Scorer().score).toList(),
      startSearching: true,
    );
    s.log(
      'Matching timing report=$reference '
      'waitBeforeClaimMs=${job.updatedAt.difference(job.runAt).inMilliseconds} '
      'normalisationMs=$normalisationMs embeddingMs=$embeddingMs '
      'candidateApplyMs=${phaseTimer.elapsedMilliseconds} '
      'totalMs=${DateTime.now().toUtc().difference(createdAt).inMilliseconds}',
    );
  }

  @override
  Future<void> failed(Session session, WorkItem job) async {
    final s = session;
    final event = await s.db.transaction<DeskEvent?>((tx) async {
      final failed = await WorkItem.db.findById(
        s,
        job.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (failed == null ||
          failed.state != WorkState.failed ||
          failed.attempts != job.attempts ||
          (job.state != WorkState.failed &&
              failed.updatedAt != job.updatedAt)) {
        return null;
      }
      final report = await LostReport.db.findById(
        s,
        job.payload.entityId!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (report == null ||
          report.venueId != job.venueId ||
          !CandidateQuery.openReports.contains(report.status)) {
        return null;
      }
      await AuditEvent.db.insertRow(
        s,
        AuditEvent(
          venueId: report.venueId,
          entityType: 'report',
          entityId: report.id!,
          action: 'match_failed',
          payload: AuditPayload(
            summary: 'Matching unavailable; staff can search again',
            data: {},
          ),
        ),
        transaction: tx,
      );
      return DeskEvent(
        kind: 'reportStatus',
        venueId: report.venueId,
        reportId: report.id,
        at: DateTime.now().toUtc(),
      );
    });
    if (event != null) {
      await s.messages.postMessage('venue_${event.venueId}', event);
    }
  }
}
