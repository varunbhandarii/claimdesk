import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

abstract class JobHandler {
  String get kind;
  Future<void> run(Session session, WorkItem job);
  Future<void> failed(Session session, WorkItem job) async {}
}

/// A claim is fenced by its timestamp and attempt, not just its running state.
/// Heartbeats extend the lease without changing this claim identity.
class JobClaim {
  static Expression matches(WorkItemTable t, WorkItem job) =>
      t.id.equals(job.id!) &
      t.state.equals(WorkState.running) &
      t.attempts.equals(job.attempts) &
      t.updatedAt.equals(job.updatedAt);
  static Future<bool> current(
    Session session,
    WorkItem job, {
    Transaction? transaction,
    bool lock = false,
  }) async =>
      (await WorkItem.db.findFirstRow(
        session,
        where: (t) => matches(t, job),
        transaction: transaction,
        lockMode: lock ? LockMode.forUpdate : null,
      )) !=
      null;
}
