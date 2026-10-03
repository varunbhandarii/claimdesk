import 'package:serverpod/serverpod.dart';
import '../../ai/providers.dart';
import '../../ai/report_normaliser.dart';
import '../../ai/text_template.dart';
import '../../generated/protocol.dart';
import '../../matching/candidate_query.dart';
import '../../matching/match_service.dart';
import '../../matching/scorer.dart';
import '../../matching/apply_profile.dart';
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
    List<double>? draftVector;
    int? draftMs;
    var normalisationMs = 0;
    var reuseDraft = false;
    List<Zone>? zones;
    if (report.attributes == null) {
      // Use the same venue metadata for both passes, including group scoring.
      zones = await Zone.db.find(
        s,
        where: (t) => t.venueId.equals(report!.venueId),
      );
      final zone = report.zoneId == null
          ? null
          : zones.where((z) => z.id == report!.zoneId).firstOrNull;
      final hints = ReportHints(
        categoryHint: report.categoryHint,
        colourHints: report.colourHints,
        brandHint: report.brandHint,
        zoneName: zone?.name,
        whereText: report.whereText,
      );
      final normaliseTimer = Stopwatch()..start();
      // Observe rejection immediately, even if the first pass fails before await.
      final refined = Providers.normaliser
          .normalise(report.rawText, hints)
          .then<NormaliseResult>(
            (result) {
              normaliseTimer.stop();
              return result;
            },
            onError: (Object _, StackTrace _) {
              normaliseTimer.stop();
              return const NormaliseResult(
                attributes: null,
                outcome: 'transport_error',
              );
            },
          );
      try {
        final draft = await HintNormaliser().normalise(report.rawText, hints);
        draftVector = await Providers.embedder.embedQuery(
          TextTemplate.render(draft.attributes!),
        );
        _validateEmbedding(draftVector);
        final temporary = report.copyWith(
          attributes: draft.attributes,
          embedding: Vector(draftVector),
          embeddingModel: Providers.embedder.modelId,
        );
        final draftProfile = ApplyProfile();
        final rows = await CandidateQuery().forReport(
          s,
          temporary,
          profile: draftProfile,
          zones: zones,
        );
        await MatchService().apply(
          s,
          job,
          report,
          rows.map(const Scorer().score).toList(),
          startSearching: true,
          draft: true,
          profile: draftProfile,
        );
        s.log(draftProfile.line(reference, draft: true));
        draftMs = DateTime.now().toUtc().difference(createdAt).inMilliseconds;
      } catch (_) {
        // Draft availability is best effort; the durable refined path still runs.
        draftVector = null;
        s.log('Preliminary matching unavailable; continuing refined matching');
      }
      final result = await refined;
      normalisationMs = normaliseTimer.elapsedMilliseconds;
      if (result.attributes == null) {
        throw StateError('Normalisation returned no attributes');
      }
      s.log(
        'Report normalisation ${result.outcome} in ${result.attempts.fold<int>(0, (total, attempt) => total + attempt.latencyMs)} ms',
      );
      reuseDraft = result.outcome == 'fallback_hints' && draftVector != null;
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
    phaseTimer.reset();
    if (report.embedding == null) {
      final embeddingTimer = Stopwatch()..start();
      final values = reuseDraft
          ? draftVector!
          : await Providers.embedder.embedQuery(
              TextTemplate.render(report.attributes!),
            );
      s.log(
        'Report query embedding completed in ${embeddingTimer.elapsedMilliseconds} ms',
      );
      _validateEmbedding(values);
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
    final profile = ApplyProfile();
    final rows = await CandidateQuery().forReport(
      s,
      report,
      profile: profile,
      zones: zones,
    );
    await MatchService().apply(
      s,
      job,
      report,
      rows.map(const Scorer().score).toList(),
      startSearching: true,
      profile: profile,
    );
    s.log(profile.line(reference, draft: false));
    s.log(
      'Matching timing report=$reference '
      'waitBeforeClaimMs=${job.updatedAt.difference(job.runAt).inMilliseconds} '
      'draftMs=${draftMs ?? 0} '
      'normalisationMs=$normalisationMs embeddingMs=$embeddingMs '
      'candidateApplyMs=${phaseTimer.elapsedMilliseconds} '
      'totalMs=${DateTime.now().toUtc().difference(createdAt).inMilliseconds}',
    );
  }

  void _validateEmbedding(List<double> values) {
    if (values.length != 1536 || values.any((value) => !value.isFinite)) {
      throw const FormatException('Invalid report embedding');
    }
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
