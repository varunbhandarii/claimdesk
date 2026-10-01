import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../jobs/job_queue.dart';

class MatchJobs {
  static Future<WorkItem> report(
    Session s,
    LostReport report, {
    Transaction? transaction,
  }) => _enqueue(s, report.venueId, report.id!, 'match_report', 4, transaction);
  static Future<WorkItem> item(
    Session s,
    FoundItem item, {
    Transaction? transaction,
  }) => _enqueue(s, item.venueId, item.id!, 'match_item', 3, transaction);
  static Future<WorkItem> _enqueue(
    Session s,
    UuidValue venueId,
    UuidValue entityId,
    String kind,
    int attempts,
    Transaction? transaction,
  ) async {
    final identifier = '${kind}_$entityId';
    Future<WorkItem> write(Transaction tx) async {
      await s.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@identifier, 0))',
        parameters: QueryParameters.named({'identifier': identifier}),
        transaction: tx,
      );
      final existing = await WorkItem.db.findFirstRow(
        s,
        where: (t) => t.identifier.equals(identifier),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (existing != null && existing.venueId != venueId) {
        throw ArgumentError('Work belongs to another venue');
      }
      // The general queue replaces identifiers; matching keeps pending work intact.
      if (existing?.state == WorkState.pending) return existing!;
      return JobQueue.enqueue(
        s,
        kind: kind,
        venueId: venueId,
        payload: WorkPayload(entityId: entityId, data: {}),
        identifier: identifier,
        maxAttempts: attempts,
        transaction: tx,
      );
    }

    return transaction == null ? s.db.transaction(write) : write(transaction);
  }
}
