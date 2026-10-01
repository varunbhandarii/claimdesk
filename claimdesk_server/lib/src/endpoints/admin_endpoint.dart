import 'package:serverpod/serverpod.dart';

import '../services/seed_service.dart';
import '../services/demo_inventory_service.dart';
import '../generated/protocol.dart';
import '../jobs/job_queue.dart';

class AdminEndpoint extends Endpoint {
  @override
  bool get logSessions => false;
  Future<WorkItem> runNightly(Session session, String secret) async {
    _authorize(session, secret);
    return JobQueue.enqueue(
      session,
      kind: 'nightly',
      payload: WorkPayload(data: {}),
      identifier: 'nightly_manual_${DateTime.now().microsecondsSinceEpoch}',
      maxAttempts: 3,
    );
  }

  Future<int> seedDemoItems(Session session, String secret) async {
    _authorize(session, secret);
    return DemoInventoryService.items(session);
  }

  Future<int> seedDemoReports(Session session, String secret) async {
    _authorize(session, secret);
    return DemoInventoryService.reports(session);
  }

  void _authorize(Session session, String secret) {
    if (!SeedService.acceptsSecret(secret, session.passwords['seedSecret'])) {
      throw Exception('Demo seed access denied');
    }
  }

  Future<({UuidValue venueId, UuidValue supervisorId, UuidValue staffId})>
  seedDemo(
    Session session,
    String secret,
  ) async {
    if (!SeedService.acceptsSecret(secret, session.passwords['seedSecret'])) {
      throw Exception('Demo seed access denied');
    }
    return SeedService.seedDemo(session);
  }
}
