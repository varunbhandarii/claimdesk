import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../jobs/job_handler.dart';
import 'candidate_query.dart';
import 'scorer.dart';
import 'apply_profile.dart';

class MatchService {
  Future<void> apply(
    Session s,
    WorkItem job,
    LostReport snapshot,
    List<ScoredCandidate> scored, {
    bool completeReportSet = true,
    bool startSearching = false,
    bool draft = false,
    String? algorithmVersion,
    ApplyProfile? profile,
  }) async {
    Future<T> locked<T>(Future<T> Function() query) =>
        profile == null ? query() : profile.lock(query);
    Future<T> written<T>(Future<T> Function() query) =>
        profile == null ? query() : profile.write(query);
    final version =
        algorithmVersion ??
        (draft ? '${Scorer.algorithmVersion}-draft' : Scorer.algorithmVersion);
    final transactionTimer = Stopwatch()..start();
    final events = await s.db.transaction((tx) async {
      if (profile != null) profile.applyAttempts++;
      if (!await locked(
        () => JobClaim.current(s, job, transaction: tx, lock: true),
      )) {
        return <DeskEvent>[];
      }
      final report = await locked(
        () => LostReport.db.findById(
          s,
          snapshot.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ),
      );
      if (report == null ||
          report.venueId != job.venueId ||
          !CandidateQuery.openReports.contains(report.status) ||
          report.embeddingModel != snapshot.embeddingModel ||
          report.updatedAt != snapshot.updatedAt) {
        return <DeskEvent>[];
      }
      final old = await locked(
        () => ItemMatch.db.find(
          s,
          where: (t) => t.reportId.equals(report.id!),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ),
      );
      final byItem = {for (final row in old) row.itemId: row};
      final retained = <ItemMatch>[];
      final proposed = <ItemMatch>[];
      final now = DateTime.now().toUtc();
      for (final candidate in Scorer.kept(scored)) {
        final input = candidate.candidate.item;
        final item = await locked(
          () => FoundItem.db.findById(
            s,
            input.id!,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          ),
        );
        if (item == null ||
            item.venueId != report.venueId ||
            item.status != ItemStatus.unclaimed ||
            item.captionText != input.captionText ||
            item.embeddingModel != input.embeddingModel) {
          continue;
        }
        final previous = byItem[item.id];
        if (previous != null && previous.state != MatchState.pending) continue;
        final value = ItemMatch(
          id: previous?.id,
          venueId: report.venueId,
          reportId: report.id!,
          itemId: item.id!,
          score: candidate.score,
          label: candidate.label,
          rank: 1,
          explanation: candidate.explanation,
          algorithmVersion: version,
          createdAt: previous?.createdAt ?? now,
          updatedAt: now,
        );
        retained.add(value);
        if (previous == null) proposed.add(value);
      }
      if (!completeReportSet) {
        final updating = retained.map((r) => r.itemId).toSet();
        retained.addAll(
          old.where(
            (r) =>
                r.state == MatchState.pending && !updating.contains(r.itemId),
          ),
        );
      }
      retained.sort((a, b) {
        final d = b.score.compareTo(a.score);
        return d == 0 ? a.itemId.toString().compareTo(b.itemId.toString()) : d;
      });
      final kept = [
        for (var n = 0; n < retained.length && n < 5; n++)
          if (n < 3 || retained[n].score >= .45) retained[n],
      ];
      final keptIds = kept.map((r) => r.itemId).toSet();
      for (final row in old.where(
        (r) => r.state == MatchState.pending && !keptIds.contains(r.itemId),
      )) {
        await written(() => ItemMatch.db.deleteRow(s, row, transaction: tx));
      }
      final all = [...kept, ...old.where((r) => r.state != MatchState.pending)]
        ..sort((a, b) => b.score.compareTo(a.score));
      final events = <DeskEvent>[];
      for (final row in kept) {
        final ranked = row.copyWith(
          rank: all.indexWhere((r) => r.itemId == row.itemId) + 1,
        );
        final saved = row.id == null
            ? await written(
                () => ItemMatch.db.insertRow(s, ranked, transaction: tx),
              )
            : await written(
                () => ItemMatch.db.updateRow(s, ranked, transaction: tx),
              );
        if (proposed.contains(row) &&
            {'strong', 'possible'}.contains(row.label)) {
          events.add(
            DeskEvent(
              kind: 'matchCreated',
              venueId: report.venueId,
              reportId: report.id,
              itemId: row.itemId,
              matchId: saved.id,
              at: now,
            ),
          );
        }
        if (!draft &&
            previousVersion(old, row.itemId)?.endsWith('-draft') == true) {
          events.add(
            DeskEvent(
              kind: 'matchStatus',
              venueId: report.venueId,
              reportId: report.id,
              itemId: row.itemId,
              matchId: saved.id,
              at: now,
            ),
          );
        }
      }
      if (startSearching && report.status == ReportStatus.received) {
        await written(
          () => LostReport.db.updateRow(
            s,
            report.copyWith(status: ReportStatus.searching, updatedAt: now),
            transaction: tx,
          ),
        );
        events.add(
          DeskEvent(
            kind: 'reportStatus',
            venueId: report.venueId,
            reportId: report.id,
            at: now,
          ),
        );
      }
      if (completeReportSet && !draft) {
        if (!(startSearching && report.status == ReportStatus.received)) {
          events.add(
            DeskEvent(
              kind: 'reportStatus',
              venueId: report.venueId,
              reportId: report.id,
              at: now,
            ),
          );
        }
        Future<void> audit() async {
          await AuditEvent.db.insertRow(
            s,
            AuditEvent(
              venueId: report.venueId,
              entityType: 'report',
              entityId: report.id!,
              action: 'match_completed',
              payload: AuditPayload(
                summary: 'Report compared with found items',
                data: {'algorithmVersion': version},
              ),
            ),
            transaction: tx,
          );
        }

        if (profile == null) {
          await audit();
        } else {
          await profile.audit(audit);
        }
      }
      return events;
    });
    if (profile != null) {
      profile.transactionMs += transactionTimer.elapsedMilliseconds;
    }
    final eventTimer = Stopwatch()..start();
    for (final event in events) {
      await s.messages.postMessage('venue_${event.venueId}', event);
    }
    if (profile != null) profile.eventsMs += eventTimer.elapsedMilliseconds;
  }

  String? previousVersion(List<ItemMatch> rows, UuidValue itemId) {
    for (final row in rows) {
      if (row.itemId == itemId) return row.algorithmVersion;
    }
    return null;
  }
}
