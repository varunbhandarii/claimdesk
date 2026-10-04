import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/signed_links.dart';
import 'package:claimdesk_server/src/web/public/tag_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Signed shelf tags', (builder, endpoints) {
    late Session s;
    late Venue venue;
    late FoundItem item;
    late RelicRouter router;
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final stranger = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Desk staff',
        ),
      );
      final zone = await Zone.db.insertRow(
        s,
        Zone(venueId: venue.id!, name: 'Pool deck', adjacentZoneIds: []),
      );
      item = await makeItem(s, venue.id!, zoneId: zone.id, refCode: 'ABC234');
      item = await FoundItem.db.updateRow(
        s,
        item.copyWith(
          photoPath: 'FORBIDDEN-PHOTO',
          privateNotes: 'FORBIDDEN-NOTES',
          finderName: 'FORBIDDEN-FINDER',
          valueBand: ValueBand.from100to499,
          restricted: true,
          storageBin: 'Bin B2',
          status: ItemStatus.disposed,
          attributes: ItemAttributes(
            category: 'wallet_or_purse',
            colours: ['blue'],
            marks: [],
            description: 'FORBIDDEN-DESCRIPTION',
            personalDataKinds: [],
            keywords: [],
            source: 'staff_typed',
          ),
        ),
      );
      await templates.loadAll(Directory('web/templates'));
      router = RelicRouter();
      router.get('/tag/:itemId', (req) => TagRoute().handleCall(s, req));
    });
    Future<Response> call(Uri uri) async =>
        await router(RequestInternal.create(Method.get, uri, Object()))
            as Response;
    test(
      'valid tag shows only shelf fields and QR with private public headers',
      () async {
        final uri = Uri.parse(await endpoints.item.tagLink(member, item.id!));
        final response = await call(uri);
        expect(response.statusCode, 200);
        final html = await response.readAsString();
        for (final field in [
          'Test desk',
          'ABC234',
          'wallet or purse',
          'blue',
          'Pool deck',
          'Bin B2',
          '<svg',
        ]) {
          expect(html, contains(field));
        }
        for (final forbidden in [
          'FORBIDDEN',
          'from100to499',
          'public.css',
          'public/header',
          '<img',
        ]) {
          expect(html, isNot(contains(forbidden)));
        }
        expect(html, matches(RegExp(r'href="[^"]*tag@[a-f0-9]+\.css"')));
        expect(response.headers['cache-control'], ['no-store']);
        expect(response.headers['x-robots-tag'], ['noindex']);
        expect(response.headers['referrer-policy'], ['no-referrer']);
        // A terminal item's tag still opens its record after staff sign-in.
        expect(
          (await endpoints.item.findByRefCode(member, venue.id!, 'abc234'))!.id,
          item.id,
        );
        expect(
          SignedLinks.webUrl(
            s,
            '/app/',
            query: {'item': 'ABC234'},
          ).queryParameters,
          {'item': 'ABC234'},
        );
      },
    );
    test(
      'expiry, excessive lifetime, tampering and another item get plain 404',
      () async {
        final now = DateTime.now().toUtc();
        final exp = now.millisecondsSinceEpoch ~/ 1000;
        Uri url(int at, String sig) => SignedLinks.webUrl(
          s,
          '/tag/${item.id}',
          query: {'exp': '$at', 'sig': sig},
        );
        expect(
          (await call(
            url(exp, SignedLinks.tagSignature(s, item.id!, exp)),
          )).statusCode,
          404,
        );
        final tooFar = exp + 86401;
        expect(
          (await call(
            url(tooFar, SignedLinks.tagSignature(s, item.id!, tooFar)),
          )).statusCode,
          404,
        );
        expect((await call(url(exp + 60, 'a' * 64))).statusCode, 404);
        final valid = Uri.parse(SignedLinks.tagUrl(s, item.id!));
        expect(
          (await call(
            valid.replace(path: '/tag/${const Uuid().v4()}'),
          )).statusCode,
          404,
        );
        expect(
          (await call(valid.replace(path: '/tag/not-a-uuid'))).statusCode,
          404,
        );
        expect(
          SignedLinks.verifyTag(
            s,
            item.id!,
            valid.queryParameters['exp'],
            valid.queryParameters['sig'],
            now: now,
          ),
          true,
        );
        await expectLater(
          endpoints.item.tagLink(stranger, item.id!),
          throwsA(isA<NotAMemberException>()),
        );
        await expectLater(
          endpoints.item.findByRefCode(stranger, venue.id!, 'ABC234'),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
    test(
      'a separately signed other-venue tag cannot expose the first item',
      () async {
        final other = await makeVenue(s, slug: 'other-tag');
        final otherItem = await makeItem(s, other.id!, refCode: 'OTHER1');
        final response = await call(
          Uri.parse(SignedLinks.tagUrl(s, otherItem.id!)),
        );
        final html = await response.readAsString();
        expect(html, contains('OTHER1'));
        expect(html, isNot(contains('ABC234')));
        await expectLater(
          endpoints.item.tagLink(member, otherItem.id!),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
  });
}
