import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../jobs/job_handler.dart';
import 'candidate_query.dart';
import 'scorer.dart';

class MatchService {
  Future<void> apply(
    Session s,
    WorkItem job,
    LostReport snapshot,
    List<ScoredCandidate> scored, {
    bool completeReportSet = true,
    bool startSearching = false,
  }) async {
    final events = await s.db.transaction((tx) async {
      if (!await JobClaim.current(s, job, transaction: tx, lock: true)) {
        return <DeskEvent>[];
      }
      final report = await LostReport.db.findById(
        s,
        snapshot.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (report == null ||
          report.venueId != job.venueId ||
          !CandidateQuery.openReports.contains(report.status) ||
          report.embeddingModel != snapshot.embeddingModel ||
          report.updatedAt != snapshot.updatedAt) {
        return <DeskEvent>[];
      }
      final old = await ItemMatch.db.find(
        s,
        where: (t) => t.reportId.equals(report.id!),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final byItem = {for (final row in old) row.itemId: row};
      final retained = <ItemMatch>[];
      final proposed = <ItemMatch>[];
      final now = DateTime.now().toUtc();
      for (final candidate in Scorer.kept(scored)) {
        final input = candidate.candidate.item;
        final item = await FoundItem.db.findById(
          s,
          input.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
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
          algorithmVersion: Scorer.algorithmVersion,
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
        await ItemMatch.db.deleteRow(s, row, transaction: tx);
      }
      final all = [...kept, ...old.where((r) => r.state != MatchState.pending)]
        ..sort((a, b) => b.score.compareTo(a.score));
      final events = <DeskEvent>[];
      for (final row in kept) {
        final ranked = row.copyWith(
          rank: all.indexWhere((r) => r.itemId == row.itemId) + 1,
        );
        final saved = row.id == null
            ? await ItemMatch.db.insertRow(s, ranked, transaction: tx)
            : await ItemMatch.db.updateRow(s, ranked, transaction: tx);
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
      }
      if (startSearching && report.status == ReportStatus.received) {
        await LostReport.db.updateRow(
          s,
          report.copyWith(status: ReportStatus.searching, updatedAt: now),
          transaction: tx,
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
      if (completeReportSet) {
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
        await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: report.venueId,
            entityType: 'report',
            entityId: report.id!,
            action: 'match_completed',
            payload: AuditPayload(
              summary: 'Report compared with found items',
              data: {'algorithmVersion': Scorer.algorithmVersion},
            ),
          ),
          transaction: tx,
        );
      }
      return events;
    });
    for (final event in events) {
      await s.messages.postMessage('venue_${event.venueId}', event);
    }
  }
}
