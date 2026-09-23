import 'package:claimdesk_server/src/access/venue_guard.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

class _SupervisorGuard extends Endpoint with VenueGuard {}

void main() {
  withServerpod('Given venue memberships', (builder, endpoints) {
    late Session session;
    late Venue venue;
    late Zone zone;
    setUp(() async {
      session = builder.build();
      venue = await makeVenue(session);
      zone = await Zone.db.insertRow(
        session,
        Zone(venueId: venue.id!, name: 'Front desk', adjacentZoneIds: []),
      );
      await StaffMembership.db.insertRow(
        session,
        StaffMembership(
          authUserId: actorId,
          venueId: venue.id!,
          displayName: 'Test staff',
        ),
      );
    });

    test(
      'when a member calls then returns only their venue and zones',
      () async {
        final other = await makeVenue(session, slug: 'another-desk');
        await Zone.db.insertRow(
          session,
          Zone(venueId: other.id!, name: 'Private zone', adjacentZoneIds: []),
        );
        final signedIn = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            actorId.uuid,
            {},
          ),
        );
        expect(
          (await endpoints.venue.getVenue(signedIn, venue.id!)).id,
          venue.id,
        );
        expect(
          (await endpoints.venue.zones(signedIn, venue.id!)).map((z) => z.id),
          [zone.id],
        );
        expect(
          (await endpoints.venue.myMemberships(signedIn)).map((m) => m.venueId),
          [venue.id],
        );
      },
    );

    test(
      'when a nonmember calls then rejects all venue data with typed error',
      () async {
        final other = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            const Uuid().v4(),
            {},
          ),
        );
        for (final call in [
          () => endpoints.venue.getVenue(other, venue.id!),
          () => endpoints.venue.zones(other, venue.id!),
        ]) {
          await expectLater(
            call(),
            throwsA(
              isA<NotAMemberException>().having(
                (e) => e.venueId,
                'venueId',
                venue.id,
              ),
            ),
          );
        }
        expect(await endpoints.venue.myMemberships(other), isEmpty);
      },
    );

    test(
      'when anonymous then authentication fails before venue access',
      () async {
        final anonymous = builder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );
        await expectLater(
          endpoints.venue.getVenue(anonymous, venue.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        await expectLater(
          endpoints.venue.zones(anonymous, venue.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        await expectLater(
          endpoints.venue.myMemberships(anonymous),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      },
    );

    test(
      'when supervisor access is required then staff is refused and supervisor succeeds',
      () async {
        final signedIn = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                actorId.uuid,
                {},
              ),
            )
            .build();
        final guard = _SupervisorGuard();
        await expectLater(
          guard.requireMembership(signedIn, venue.id!, supervisor: true),
          throwsA(isA<NotAMemberException>()),
        );
        final member = (await StaffMembership.db.find(session)).single;
        await StaffMembership.db.updateRow(
          session,
          member.copyWith(role: StaffRole.supervisor),
        );
        expect(
          (await guard.requireMembership(
            signedIn,
            venue.id!,
            supervisor: true,
          )).id,
          member.id,
        );
      },
    );
  });
}
