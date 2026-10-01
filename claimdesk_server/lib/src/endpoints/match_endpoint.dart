import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../access/venue_guard.dart';
import '../generated/protocol.dart';
import '../matching/candidate_query.dart';
import '../matching/match_jobs.dart';
import '../matching/scorer.dart';
import '../services/staff_views.dart';
import '../db/transactions.dart';

class MatchEndpoint extends Endpoint with VenueGuard {
  @override
  bool get logSessions => false;
  Future<List<ReportAnswer>> answers(Session session, UuidValue matchId) async {
    final match = await _match(session, matchId);
    return ReportAnswer.db.find(
      session,
      where: (t) =>
          t.matchId.equals(match.id!) & t.venueId.equals(match.venueId),
      orderBy: (t) => t.createdAt,
    );
  }

  Future<List<MatchCard>> inbox(Session session, UuidValue venueId) async {
    await requireMembership(session, venueId);
    final rows = await ItemMatch.db.find(
      session,
      where: (t) =>
          t.venueId.equals(venueId) &
          t.state.equals(MatchState.pending) &
          t.label.inSet({'strong', 'possible'}),
      orderByList: (t) => [t.createdAt.desc(), t.rank, t.id.desc()],
      limit: 100,
    );
    return _cards(session, venueId, rows);
  }

  Future<List<MatchCard>> forReport(Session session, UuidValue reportId) async {
    final report = await _report(session, reportId);
    final rows = await ItemMatch.db.find(
      session,
      where: (t) =>
          t.venueId.equals(report.venueId) & t.reportId.equals(reportId),
    );
    _sort(rows);
    return _cards(session, report.venueId, rows);
  }

  Future<List<MatchCard>> forItem(Session session, UuidValue itemId) async {
    final item = await FoundItem.db.findById(session, itemId);
    if (item == null) throw ArgumentError('Item not found');
    await requireMembership(session, item.venueId);
    final rows = await ItemMatch.db.find(
      session,
      where: (t) => t.venueId.equals(item.venueId) & t.itemId.equals(itemId),
    );
    _sort(rows);
    return _cards(session, item.venueId, rows);
  }

  Future<WorkItem> rematch(Session session, UuidValue reportId) async {
    final report = await _report(session, reportId);
    if (!CandidateQuery.openReports.contains(report.status)) {
      throw ArgumentError('Report is no longer searching');
    }
    return MatchJobs.report(session, report);
  }

  Future<MatchCard> confirm(Session session, UuidValue matchId) async {
    final authorized = await _match(session, matchId);
    final events = await serializable(session, (tx) async {
      final row = await _lockedMatch(session, matchId, authorized.venueId, tx);
      if (row.state != MatchState.pending) {
        _bad(matchId, 'Only a proposed match can be confirmed');
      }
      final report = await LostReport.db.findById(
        session,
        row.reportId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final item = await FoundItem.db.findById(
        session,
        row.itemId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (report == null ||
          item == null ||
          report.venueId != row.venueId ||
          item.venueId != row.venueId ||
          !CandidateQuery.openReports.contains(report.status) ||
          !{ItemStatus.unclaimed, ItemStatus.matched}.contains(item.status)) {
        _bad(matchId, 'This report or item is no longer available');
      }
      final decided = await ItemMatch.db.find(
        session,
        where: (t) =>
            t.venueId.equals(row.venueId) &
            t.state.equals(MatchState.confirmed) &
            (t.itemId.equals(row.itemId) | t.reportId.equals(row.reportId)),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (decided.any(
        (m) => m.itemId == row.itemId && m.reportId != row.reportId,
      )) {
        _bad(matchId, 'Item already proposed to another report');
      }
      if (decided.any(
        (m) => m.reportId == row.reportId && m.itemId != row.itemId,
      )) {
        _bad(matchId, 'Report already has a confirmed match; undo it first');
      }
      final now = DateTime.now().toUtc();
      final actor = session.authenticated!.authUserId;
      await ItemMatch.db.updateRow(
        session,
        row.copyWith(
          state: MatchState.confirmed,
          decidedByAuthUserId: actor,
          decidedAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      final superseded = await ItemMatch.db.updateWhere(
        session,
        columnValues: (t) => [t.state(MatchState.superseded), t.updatedAt(now)],
        where: (t) =>
            t.venueId.equals(row.venueId) &
            t.id.notEquals(matchId) &
            t.state.equals(MatchState.pending) &
            (t.reportId.equals(row.reportId) | t.itemId.equals(row.itemId)),
        transaction: tx,
      );
      await LostReport.db.updateRow(
        session,
        report.copyWith(status: ReportStatus.possibleMatch, updatedAt: now),
        transaction: tx,
      );
      await FoundItem.db.updateRow(
        session,
        item.copyWith(status: ItemStatus.matched, updatedAt: now),
        transaction: tx,
      );
      await _audit(
        session,
        tx,
        row,
        report,
        item,
        'match_confirmed',
        'Match confirmed',
      );
      return _events(row, now, superseded);
    });
    await _post(session, events);
    return (await _cards(session, authorized.venueId, [
      await _match(session, matchId),
    ])).single;
  }

  Future<MatchCard> reject(
    Session session,
    UuidValue matchId,
    String reason,
  ) async {
    final authorized = await _match(session, matchId);
    final clean = reason.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').trim();
    if (clean.isEmpty || clean.length > 300) {
      throw ArgumentError('Give a reason of 1 to 300 characters');
    }
    final events = await serializable(session, (tx) async {
      final row = await _lockedMatch(session, matchId, authorized.venueId, tx);
      if (!{MatchState.pending, MatchState.confirmed}.contains(row.state)) {
        _bad(matchId, 'This match has already been decided');
      }
      final report = await LostReport.db.findById(
        session,
        row.reportId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final item = await FoundItem.db.findById(
        session,
        row.itemId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (report == null ||
          item == null ||
          report.venueId != row.venueId ||
          item.venueId != row.venueId) {
        _bad(matchId, 'Match parents are unavailable');
      }
      final confirmed = row.state == MatchState.confirmed;
      if (confirmed &&
          (item.status != ItemStatus.matched ||
              !{
                ReportStatus.possibleMatch,
                ReportStatus.readyForPickup,
              }.contains(report.status) ||
              await ReleaseRecord.db.findFirstRow(
                    session,
                    where: (t) => t.itemId.equals(item.id!),
                    transaction: tx,
                  ) !=
                  null)) {
        _bad(matchId, 'A released match cannot be undone');
      }
      final now = DateTime.now().toUtc();
      await ItemMatch.db.updateRow(
        session,
        row.copyWith(
          state: MatchState.rejected,
          decidedByAuthUserId: session.authenticated!.authUserId,
          decidedAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      var restored = <ItemMatch>[];
      if (confirmed) {
        await FoundItem.db.updateRow(
          session,
          item.copyWith(status: ItemStatus.unclaimed, updatedAt: now),
          transaction: tx,
        );
        await LostReport.db.updateRow(
          session,
          report.copyWith(status: ReportStatus.searching, updatedAt: now),
          transaction: tx,
        );
        restored = await ItemMatch.db.updateWhere(
          session,
          columnValues: (t) => [
            t.state(MatchState.pending),
            t.decidedByAuthUserId(null),
            t.decidedAt(null),
            t.updatedAt(now),
          ],
          where: (t) =>
              t.venueId.equals(row.venueId) &
              t.state.equals(MatchState.superseded) &
              (t.reportId.equals(row.reportId) | t.itemId.equals(row.itemId)),
          transaction: tx,
        );
      } else if (report.status == ReportStatus.possibleMatch &&
          await ItemMatch.db.count(
                session,
                where: (t) =>
                    t.reportId.equals(row.reportId) &
                    t.state.inSet({MatchState.pending, MatchState.confirmed}),
                transaction: tx,
              ) ==
              0) {
        await LostReport.db.updateRow(
          session,
          report.copyWith(status: ReportStatus.searching, updatedAt: now),
          transaction: tx,
        );
      }
      await _audit(session, tx, row, report, item, 'match_rejected', clean);
      return _events(row, now, restored);
    });
    await _post(session, events);
    return (await _cards(session, authorized.venueId, [
      await _match(session, matchId),
    ])).single;
  }

  Future<LostReport> _report(Session s, UuidValue id) async {
    final row = await LostReport.db.findById(s, id);
    if (row == null) throw ArgumentError('Report not found');
    await requireMembership(s, row.venueId);
    return row;
  }

  Future<ItemMatch> _match(Session s, UuidValue id) async {
    final row = await ItemMatch.db.findById(s, id);
    if (row == null) _bad(id, 'Match not found');
    await requireMembership(s, row.venueId);
    return row;
  }

  Future<ItemMatch> _lockedMatch(
    Session s,
    UuidValue id,
    UuidValue venueId,
    Transaction tx,
  ) async {
    final row = await ItemMatch.db.findById(
      s,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (row == null || row.venueId != venueId) _bad(id, 'Match not found');
    return row;
  }

  Never _bad(UuidValue id, String message) =>
      throw MatchStateException(message: message, matchId: id);
  void _sort(List<ItemMatch> rows) {
    int order(MatchState s) => switch (s) {
      MatchState.confirmed => 0,
      MatchState.pending => 1,
      MatchState.rejected => 2,
      MatchState.superseded => 3,
    };
    rows.sort((a, b) {
      final d = order(a.state).compareTo(order(b.state));
      return d == 0 ? a.rank.compareTo(b.rank) : d;
    });
  }

  Future<List<MatchCard>> _cards(
    Session s,
    UuidValue venueId,
    List<ItemMatch> rows,
  ) async {
    if (rows.isEmpty) return [];
    final items = await FoundItem.db.find(
      s,
      where: (t) =>
          t.venueId.equals(venueId) &
          t.id.inSet(rows.map((m) => m.itemId).toSet()),
    );
    final reports = await StaffViews.reports(
      s,
      await LostReport.db.find(
        s,
        where: (t) =>
            t.venueId.equals(venueId) &
            t.id.inSet(rows.map((m) => m.reportId).toSet()),
      ),
    );
    final byItem = {for (final item in items) item.id!: StaffViews.item(item)};
    final byReport = {for (final report in reports) report.id!: report};
    final pending = await ItemMatch.db.find(
      s,
      where: (t) =>
          t.venueId.equals(venueId) &
          t.reportId.inSet(byReport.keys.toSet()) &
          t.state.equals(MatchState.pending),
      orderByList: (t) => [t.score.desc(), t.id],
    );
    final perReport = <UuidValue, List<ItemMatch>>{};
    for (final match in pending) {
      perReport.putIfAbsent(match.reportId, () => []).add(match);
    }
    return [
      for (final row in rows)
        if (byItem[row.itemId] != null && byReport[row.reportId] != null)
          MatchCard(
            match: row,
            item: byItem[row.itemId]!,
            report: byReport[row.reportId]!,
            clearLeader:
                row.state == MatchState.pending &&
                byReport[row.reportId]!.status != ReportStatus.possibleMatch &&
                perReport[row.reportId]?.first.id == row.id &&
                Scorer.clearLeader(
                  row.score,
                  perReport[row.reportId]!.length > 1
                      ? perReport[row.reportId]![1].score
                      : null,
                ),
          ),
    ];
  }

  Future<void> _audit(
    Session s,
    Transaction tx,
    ItemMatch match,
    LostReport report,
    FoundItem item,
    String action,
    String summary,
  ) async {
    for (final entity in [
      ('report', report.id!, item.id!, item.refCode),
      ('item', item.id!, report.id!, report.refCode),
    ]) {
      await AuditEvent.db.insertRow(
        s,
        AuditEvent(
          venueId: match.venueId,
          entityType: entity.$1,
          entityId: entity.$2,
          action: action,
          actorAuthUserId: s.authenticated!.authUserId,
          payload: AuditPayload(
            summary: summary,
            data: {
              'matchId': match.id.toString(),
              'counterpartId': entity.$3.toString(),
              'counterpartRef': entity.$4,
              'itemRef': item.refCode,
              'reportRef': report.refCode,
            },
          ),
        ),
        transaction: tx,
      );
    }
  }

  List<DeskEvent> _events(
    ItemMatch row,
    DateTime now,
    List<ItemMatch> others,
  ) => [
    for (final changed in [row, ...others])
      DeskEvent(
        kind: 'matchStatus',
        venueId: row.venueId,
        matchId: changed.id,
        itemId: changed.itemId,
        reportId: changed.reportId,
        at: now,
      ),
    DeskEvent(
      kind: 'reportStatus',
      venueId: row.venueId,
      reportId: row.reportId,
      at: now,
    ),
    DeskEvent(
      kind: 'itemStatus',
      venueId: row.venueId,
      itemId: row.itemId,
      at: now,
    ),
  ];
  Future<void> _post(Session s, List<DeskEvent> events) async {
    for (final event in events) {
      await s.messages.postMessage('venue_${event.venueId}', event);
    }
  }
}
