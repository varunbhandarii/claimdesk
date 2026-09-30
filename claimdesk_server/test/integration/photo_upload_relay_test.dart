import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/photo_upload_relay.dart';
import 'package:claimdesk_server/src/services/upload_tickets.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an authenticated photo relay', (builder, endpoints) {
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final relay = PhotoUploadRelay();
    late Session session;
    late Venue venue;
    late UuidValue item;
    late DateTime expires;
    late String proof;
    setUp(() async {
      session = member.build();
      venue = await makeVenue(session);
      await StaffMembership.db.insertRow(
        session,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Staff',
        ),
      );
      item = UuidValue.fromString(const Uuid().v7());
      expires = DateTime.now().toUtc().add(const Duration(minutes: 10));
      proof = UploadTickets.sign(session, venue.id!, item, expires);
    });
    Future<Object?> check({
      Session? caller,
      String? itemOverride,
      DateTime? expiration,
      String? signature,
      String? venueOverride,
    }) => relay.authorize(
      caller ?? session,
      venue: venueOverride ?? venue.id.toString(),
      item: itemOverride ?? item.toString(),
      expires: (expiration ?? expires).microsecondsSinceEpoch.toString(),
      proof: signature ?? proof,
    );
    test(
      'member ticket requires login and binds the authorized venue and item',
      () async {
        expect(relay.requireLogin, true);
        expect(await check(), (
          venueId: venue.id!,
          itemId: item,
          expiration: expires,
        ));
      },
    );
    test(
      'anonymous callers and another staff identity cannot use a member ticket',
      () async {
        expect(await check(caller: builder.build()), isNull);
        final other = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                const Uuid().v4(),
                {},
              ),
            )
            .build();
        expect(await check(caller: other), isNull);
      },
    );
    test(
      'tampered item, signature, expired and malformed tickets are rejected',
      () async {
        expect(await check(itemOverride: const Uuid().v7()), isNull);
        expect(await check(signature: 'invalid'), isNull);
        expect(
          await check(
            expiration: DateTime.now().toUtc().subtract(
              const Duration(seconds: 1),
            ),
          ),
          isNull,
        );
        expect(await check(itemOverride: 'invalid-uuid'), isNull);
      },
    );
    test(
      'membership is checked again even for a correctly signed ticket',
      () async {
        final otherVenue = await makeVenue(session, slug: 'other-desk');
        final otherProof = UploadTickets.sign(
          session,
          otherVenue.id!,
          item,
          expires,
        );
        await expectLater(
          check(venueOverride: otherVenue.id.toString(), signature: otherProof),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
  });
}
