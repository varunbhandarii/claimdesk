import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../access/venue_guard.dart';
import '../generated/protocol.dart';

class VenueEndpoint extends Endpoint with VenueGuard {
  Future<List<StaffMembership>> myMemberships(Session session) async {
    final userId = session.authenticated!.authUserId;
    return StaffMembership.db.find(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
  }

  Future<Venue> getVenue(Session session, UuidValue venueId) async {
    await requireMembership(session, venueId);
    final venue = await Venue.db.findById(session, venueId);
    if (venue == null) {
      throw NotAMemberException(message: 'Venue unavailable', venueId: venueId);
    }
    return venue;
  }

  Future<List<Zone>> zones(Session session, UuidValue venueId) async {
    await requireMembership(session, venueId);
    return Zone.db.find(
      session,
      where: (t) => t.venueId.equals(venueId),
      orderBy: (t) => t.sortOrder,
    );
  }
}
