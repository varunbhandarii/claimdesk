import 'package:serverpod/serverpod.dart';

import '../access/venue_guard.dart';
import '../generated/protocol.dart';

/// Live desk updates are visible only to staff assigned to the venue.
class DeskStreamEndpoint extends Endpoint with VenueGuard {
  Stream<DeskEvent> watchVenue(Session session, UuidValue venueId) async* {
    await requireMembership(session, venueId);
    yield* session.messages.createStream<DeskEvent>('venue_$venueId');
  }
}
