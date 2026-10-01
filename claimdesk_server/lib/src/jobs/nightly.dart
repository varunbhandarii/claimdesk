import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'job_queue.dart';

class Nightly {
  static DateTime nextRun(DateTime now, {bool tomorrow = false}) {
    final utc = now.toUtc();
    final today = DateTime.utc(utc.year, utc.month, utc.day, 2);
    return tomorrow || !today.isAfter(utc)
        ? today.add(const Duration(days: 1))
        : today;
  }

  static Future<void> schedule(
    Session session, {
    DateTime? now,
    bool tomorrow = false,
  }) async {
    final at = nextRun(now ?? DateTime.now().toUtc(), tomorrow: tomorrow);
    final identifier = 'nightly_${at.toIso8601String().split('T').first}';
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
      if (existing == null) {
        await JobQueue.enqueue(
          session,
          kind: 'nightly',
          payload: WorkPayload(data: {}),
          identifier: identifier,
          runAt: at,
          maxAttempts: 3,
          transaction: tx,
        );
        session.log('Nightly scheduled for ${at.toIso8601String()}');
      }
    });
  }
}
