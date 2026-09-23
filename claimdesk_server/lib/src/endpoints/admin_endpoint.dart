import 'package:serverpod/serverpod.dart';

import '../services/seed_service.dart';

class AdminEndpoint extends Endpoint {
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
