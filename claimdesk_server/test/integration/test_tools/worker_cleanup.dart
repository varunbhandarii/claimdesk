import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Concurrent jobs commit through independent sessions, so their tests cannot
/// use the test framework's single rollback transaction.
Future<void> clearWorkerTestData(Session session) async {
  await WorkItem.db.deleteWhere(session, where: (_) => Constant.bool(true));
  await ReleaseRecord.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await Venue.db.deleteWhere(session, where: (_) => Constant.bool(true));
  await AuditEvent.db.deleteWhere(session, where: (_) => Constant.bool(true));
}
