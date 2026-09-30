import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Venue updates', (builder, endpoints) {
    late Venue venue;
    late Session session;
    setUp(() async {
      session = builder.build();
      venue = await makeVenue(session);
      await StaffMembership.db.insertRow(
        session,
        StaffMembership(
          authUserId: actorId,
          venueId: venue.id!,
          displayName: 'Desk staff',
        ),
      );
    });
    test('members receive their venue events only', () async {
      final member = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          actorId.uuid,
          {},
        ),
      );
      final events = <DeskEvent>[];
      final subscription = endpoints.deskStream
          .watchVenue(member, venue.id!)
          .listen(events.add);
      try {
        // Opening the stream includes an asynchronous membership query. Wait
        // for delivery rather than racing that query with database teardown.
        for (var attempt = 0; attempt < 50 && events.isEmpty; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await session.messages.postMessage(
            'venue_${venue.id}',
            DeskEvent(
              kind: 'itemStatus',
              venueId: venue.id!,
              itemId: actorId,
              at: DateTime.now(),
            ),
          );
          await flushEventQueue();
        }
        expect(events, isNotEmpty);
        expect(events.first.itemId, actorId);
        expect(events.first.kind, 'itemStatus');
        final before = events.length;
        await session.messages.postMessage(
          'venue_${const Uuid().v4()}',
          DeskEvent(
            kind: 'captionFailed',
            venueId: venue.id!,
            at: DateTime.now(),
          ),
        );
        await flushEventQueue();
        expect(events, hasLength(before));
      } finally {
        await subscription.cancel();
      }
    });
    test('nonmembers are refused when opening the stream', () async {
      final other = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          const Uuid().v4(),
          {},
        ),
      );
      await expectLater(
        endpoints.deskStream.watchVenue(other, venue.id!),
        emitsError(isA<NotAMemberException>()),
      );
    });
    test('anonymous callers cannot open the stream', () async {
      final anonymous = builder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );
      await expectLater(
        endpoints.deskStream.watchVenue(anonymous, venue.id!),
        emitsError(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
