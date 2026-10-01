import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../access/venue_guard.dart';
import '../generated/protocol.dart';

class ReportEndpoint extends Endpoint with VenueGuard {
  Future<List<LostReport>> listReports(
    Session session,
    UuidValue venueId,
    ReportFilter filter,
  ) async {
    await requireMembership(session, venueId);
    final rows = await LostReport.db.find(
      session,
      where: (t) {
        var where = t.venueId.equals(venueId);
        where &= filter.status == null
            ? t.status.inSet({
                ReportStatus.received,
                ReportStatus.searching,
                ReportStatus.possibleMatch,
                ReportStatus.readyForPickup,
              })
            : t.status.equals(filter.status!);
        if (filter.zoneId != null) where &= t.zoneId.equals(filter.zoneId);
        if (filter.category != null) {
          where &= t.categoryHint.equals(filter.category);
        }
        return where;
      },
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: 100,
    );
    return rows.map(_staffView).toList();
  }

  Future<LostReport> getReport(Session session, UuidValue reportId) async =>
      _staffView(await _authorized(session, reportId));

  Future<LostReport?> findByRefCode(
    Session session,
    UuidValue venueId,
    String refCode,
  ) async {
    await requireMembership(session, venueId);
    final code = refCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) return null;
    final row = await LostReport.db.findFirstRow(
      session,
      where: (t) => t.venueId.equals(venueId) & t.refCode.equals(code),
    );
    return row == null ? null : _staffView(row);
  }

  Future<LostReport> closeReport(
    Session session,
    UuidValue reportId,
    String reason,
  ) async {
    final report = await _authorized(session, reportId);
    final clean = reason.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').trim();
    if (clean.isEmpty || clean.length > 300) {
      throw ArgumentError('Give a reason of 1 to 300 characters');
    }
    final closed = await session.db.transaction((tx) async {
      final row = await LostReport.db.findById(
        session,
        reportId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null ||
          !{
            ReportStatus.received,
            ReportStatus.searching,
          }.contains(row.status)) {
        throw ArgumentError('Only received or searching reports can be closed');
      }
      final now = DateTime.now().toUtc();
      final updated = await LostReport.db.updateRow(
        session,
        row.copyWith(
          status: ReportStatus.closed,
          closedAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await AuditEvent.db.insertRow(
        session,
        AuditEvent(
          venueId: report.venueId,
          entityType: 'report',
          entityId: reportId,
          action: 'closed',
          actorAuthUserId: session.authenticated!.authUserId,
          payload: AuditPayload(
            summary: clean,
            fromState: row.status.name,
            toState: 'closed',
            data: {'refCode': row.refCode},
          ),
        ),
        transaction: tx,
      );
      return updated;
    });
    await session.messages.postMessage(
      'venue_${report.venueId}',
      DeskEvent(
        kind: 'reportStatus',
        venueId: report.venueId,
        reportId: reportId,
        at: closed.updatedAt,
      ),
    );
    return _staffView(closed);
  }

  Future<LostReport> _authorized(Session session, UuidValue id) async {
    final row = await LostReport.db.findById(session, id);
    if (row == null) throw ArgumentError('Report not found');
    await requireMembership(session, row.venueId);
    return row;
  }

  // Owner credentials and abuse metadata never leave through staff APIs.
  LostReport _staffView(LostReport row) =>
      row.copyWith(publicToken: '', ipHash: null, embedding: null);
}
