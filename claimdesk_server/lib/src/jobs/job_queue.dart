import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'job_wakeup.dart';

class JobQueue {
  static Duration backoff(int attempts) =>
      Duration(seconds: 5 * (1 << (attempts - 1).clamp(0, 10)));
  static Future<WorkItem> enqueue(
    Session session, {
    required String kind,
    required WorkPayload payload,
    UuidValue? venueId,
    String? identifier,
    DateTime? runAt,
    int maxAttempts = 5,
    Transaction? transaction,
  }) async {
    if (kind.isEmpty || maxAttempts < 1 || maxAttempts > 20) {
      throw ArgumentError('Invalid job configuration');
    }
    Future<WorkItem> write(Transaction tx) async {
      WorkItem? previous;
      if (identifier != null) {
        await session.db.unsafeQuery(
          'SELECT pg_advisory_xact_lock(hashtextextended(@identifier, 0))',
          parameters: QueryParameters.named({'identifier': identifier}),
          transaction: tx,
        );
        previous = await WorkItem.db.findFirstRow(
          session,
          where: (t) => t.identifier.equals(identifier),
          lockMode: LockMode.forUpdate,
          transaction: tx,
        );
        if (previous != null && previous.venueId != venueId) {
          throw ArgumentError('Job identifier belongs to another venue');
        }
      }
      final now = DateTime.now().toUtc();
      final job = WorkItem(
        id: previous?.id,
        kind: kind,
        payload: payload,
        venueId: venueId,
        identifier: identifier,
        runAt: runAt ?? now,
        maxAttempts: maxAttempts,
        createdAt: previous?.createdAt,
        updatedAt: now,
      );
      return previous == null
          ? WorkItem.db.insertRow(session, job, transaction: tx)
          : WorkItem.db.updateRow(session, job, transaction: tx);
    }

    if (transaction != null) return write(transaction);
    final job = await session.db.transaction(write);
    JobWakeup.notify(session);
    return job;
  }

  static Future<bool> cancel(Session session, String identifier) async =>
      (await WorkItem.db.updateWhere(
        session,
        columnValues: (t) => [
          t.state(WorkState.cancelled),
          t.updatedAt(DateTime.now().toUtc()),
        ],
        where: (t) =>
            t.identifier.equals(identifier) & t.state.equals(WorkState.pending),
      )).isNotEmpty;
  static Future<void> scheduleRecurring(
    Session session, {
    required String kind,
    required String identifier,
    required DateTime firstRunAt,
  }) async {
    await session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@identifier, 0))',
        parameters: QueryParameters.named({'identifier': identifier}),
        transaction: tx,
      );
      final existing = await WorkItem.db.findFirstRow(
        session,
        where: (t) => t.identifier.equals(identifier),
        transaction: tx,
      );
      if (existing == null ||
          [
            WorkState.done,
            WorkState.failed,
            WorkState.cancelled,
          ].contains(existing.state)) {
        await enqueue(
          session,
          kind: kind,
          payload: WorkPayload(data: {}),
          identifier: identifier,
          runAt: firstRunAt,
          transaction: tx,
        );
      }
    });
  }
}
