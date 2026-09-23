import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

mixin VenueGuard on Endpoint {
  @override
  bool get requireLogin => true;

  @doNotGenerate
  Future<StaffMembership> requireMembership(
    Session session,
    UuidValue venueId, {
    bool supervisor = false,
  }) async {
    final userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw NotAMemberException(message: 'Sign in required', venueId: venueId);
    }
    final membership = await StaffMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId) & t.venueId.equals(venueId),
    );
    if (membership == null) {
      throw NotAMemberException(
        message: 'Not a member of this venue',
        venueId: venueId,
      );
    }
    if (supervisor && membership.role != StaffRole.supervisor) {
      throw NotAMemberException(
        message: 'Supervisor role required',
        venueId: venueId,
      );
    }
    return membership;
  }
}
