import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:claimdesk_server/src/web/public/venue_page_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

ItemAttributes attributes(
  String category,
  List<String> colours, {
  bool personal = false,
}) => ItemAttributes(
  category: category,
  colours: colours,
  marks: ['PRIVATE-MARK'],
  description: 'PRIVATE-DESCRIPTION',
  containsPersonalData: personal,
  personalDataKinds: personal ? ['name'] : [],
  keywords: [],
  source: 'fixture',
);

void main() {
  withServerpod('Venue page recently handed in', (builder, _) {
    late Session s;
    late Venue venue;
    late Zone zone;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      zone = await Zone.db.insertRow(
        s,
        Zone(venueId: venue.id!, name: 'Pool deck', adjacentZoneIds: []),
      );
    });

    Future<void> add(
      String code,
      ItemAttributes? attrs, {
      UuidValue? venueId,
      ItemStatus status = ItemStatus.unclaimed,
      bool restricted = false,
      ValueBand value = ValueBand.under20,
      Duration ago = const Duration(days: 1),
    }) => FoundItem.db.insertRow(
      s,
      FoundItem(
        venueId: venueId ?? venue.id!,
        zoneId: zone.id,
        refCode: code,
        status: status,
        restricted: restricted,
        attributes: attrs,
        valueBand: value,
        privateNotes: 'PRIVATE-NOTES',
        storageBin: 'PRIVATE-BIN',
        foundAt: DateTime.now().toUtc().subtract(ago),
        loggedByAuthUserId: actorId,
      ),
    );

    test(
      'lists only recent, low-value, unrestricted items by colour, kind, zone and day',
      () async {
        final other = await makeVenue(s, slug: 'other-desk');
        await add('SHOWN1', attributes('umbrella', ['black']));
        await add(
          'SHOWN2',
          attributes('toy_or_plush', ['beige']),
          status: ItemStatus.matched,
          ago: const Duration(days: 2),
        );
        await add(
          'WALLET',
          attributes('wallet_or_purse', ['brown']),
          restricted: true,
        );
        await add('CARDS1', attributes('bank_card', ['blue']));
        await add(
          'LAPTOP',
          attributes('tablet_or_laptop', ['grey']),
          value: ValueBand.from500to4999,
        );
        await add(
          'NAMEID',
          attributes('backpack', ['red'], personal: true),
        );
        await add('PEND01', null, status: ItemStatus.captioning);
        await add(
          'GONE01',
          attributes('umbrella', ['red']),
          status: ItemStatus.claimed,
        );
        await add(
          'OLD001',
          attributes('umbrella', ['green']),
          ago: const Duration(days: 20),
        );
        await add(
          'ELSEWH',
          attributes('umbrella', ['white']),
          venueId: other.id,
        );
        final rows = await recentlyHandedIn(s, venue);
        expect(rows.map((r) => r['title']), [
          'Black umbrella',
          'Beige plush toy',
        ]);
        expect(rows.first['colour'], 'black');
        expect(rows.first['where'], startsWith('Pool deck · '));

        final spanish = await recentlyHandedIn(
          s,
          venue,
          lang: PublicLang.es,
        );
        expect(spanish.map((r) => r['title']), [
          'Paraguas negro',
          'Peluche beige',
        ]);
        expect(
          spanish.map((r) => r['colour']),
          rows.map((r) => r['colour']),
        );
        expect(spanish.first['where'], startsWith('Pool deck · '));

        await templates.loadAll(Directory('web/templates'));
        final router = RelicRouter()
          ..get('/v/:slug', (req) => VenuePageRoute().handleCall(s, req));
        final spanishHtml =
            await (await router(
                      RequestInternal.create(
                        Method.get,
                        Uri.parse('http://localhost/v/test-desk?lang=es'),
                        Object(),
                      ),
                    )
                    as Response)
                .readAsString();
        expect(spanishHtml, contains('Entregados recientemente'));
        expect(spanishHtml, contains('Paraguas negro'));
        expect(spanishHtml, isNot(contains('Black umbrella')));
        expect(spanishHtml, isNot(contains('Billetera café')));
        final response =
            await router(
                  RequestInternal.create(
                    Method.get,
                    Uri.parse('http://localhost/v/test-desk'),
                    Object(),
                  ),
                )
                as Response;
        final html = await response.readAsString();
        expect(html, contains('Recently handed in'));
        expect(html, contains('Black umbrella'));
        expect(html, contains('sw-black'));
        for (final hidden in [
          'SHOWN1',
          'PRIVATE-MARK',
          'PRIVATE-DESCRIPTION',
          'PRIVATE-NOTES',
          'PRIVATE-BIN',
          'Brown wallet',
          'Blue bank card',
          'Grey laptop',
          'Red backpack',
          'Red umbrella',
          'Green umbrella',
          'White umbrella',
        ]) {
          expect(html, isNot(contains(hidden)));
        }
      },
    );

    test('the section is left out when nothing qualifies', () async {
      await add(
        'WALLET',
        attributes('wallet_or_purse', ['brown']),
        restricted: true,
      );
      expect(await recentlyHandedIn(s, venue), isEmpty);
      await templates.loadAll(Directory('web/templates'));
      final router = RelicRouter()
        ..get('/v/:slug', (req) => VenuePageRoute().handleCall(s, req));
      final html =
          await (await router(
                    RequestInternal.create(
                      Method.get,
                      Uri.parse('http://localhost/v/test-desk'),
                      Object(),
                    ),
                  )
                  as Response)
              .readAsString();
      expect(html, isNot(contains('Recently handed in')));
      expect(html, contains('Lost something?'));
    });
  });
}
