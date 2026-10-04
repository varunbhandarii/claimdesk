import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/poster_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Venue poster', (builder, endpoints) {
    late Session s;
    late RelicRouter router;
    setUp(() async {
      s = builder.build();
      final venue = await makeVenue(s);
      await Venue.db.updateRow(
        s,
        venue.copyWith(
          name: 'Poster Rec Center',
          deskHours: 'Mon–Fri 7:00–22:00\nSat–Sun 9:00–20:00',
        ),
      );
      await makeVenue(s, slug: 'no-hours');
      await templates.loadAll(Directory('web/templates'));
      router = RelicRouter()
        ..get('/v/:slug/poster', (req) => PosterRoute().handleCall(s, req));
    });
    Future<Response> call(String path) async =>
        await router(
              RequestInternal.create(
                Method.get,
                Uri.parse('http://localhost$path'),
                Object(),
              ),
            )
            as Response;

    test('prints the venue, its hours, both headlines and a QR code', () async {
      final response = await call('/v/test-desk/poster');
      expect(response.statusCode, 200);
      expect(response.headers['cache-control'], ['no-cache, private']);
      expect(response.headers['x-robots-tag'], ['noindex']);
      expect(
        response.headers['content-security-policy']!.single,
        contains("script-src 'none'"),
      );
      final html = await response.readAsString();
      for (final text in [
        'Poster Rec Center',
        'Mon–Fri 7:00–22:00\nSat–Sun 9:00–20:00',
        'Lost something?',
        '¿Perdió algo?',
        'Scan to report it.',
        'Escanee para reportarlo.',
        'Found something? Hand it to the desk.',
        '¿Encontró algo? Entréguelo en el mostrador.',
        '<span>localhost:0</span><wbr><span>&#x2F;v&#x2F;test-desk</span>',
        '<svg',
      ]) {
        expect(html, contains(text), reason: text);
      }
      expect(html, isNot(contains('{{')));
      expect(html, contains('lang="es"'));
    });

    test('a venue without hours shows the ask-the-desk line', () async {
      final html = await (await call('/v/no-hours/poster')).readAsString();
      expect(html, contains('Ask the front desk for opening hours.'));
      expect(html, contains('Pregunte el horario en el mostrador.'));
    });

    test('an unknown or malformed venue is a plain 404', () async {
      expect((await call('/v/unknown-desk/poster')).statusCode, 404);
      expect((await call('/v/X/poster')).statusCode, 404);
    });
  });

  withServerpod('Poster link for supervisors', (builder, endpoints) {
    late Session s;
    late Venue venue;
    final supervisor = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final staffId = UuidValue.fromString(const Uuid().v4());
    final staff = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        staffId.uuid,
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
          displayName: 'Supervisor',
          role: StaffRole.supervisor,
        ),
      );
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: staffId,
          displayName: 'Desk staff',
        ),
      );
    });

    test(
      'supervisors get the web address; staff and strangers do not',
      () async {
        final link = await endpoints.venue.posterLink(supervisor, venue.id!);
        expect(Uri.parse(link).path, '/v/test-desk/poster');
        await expectLater(
          endpoints.venue.posterLink(staff, venue.id!),
          throwsA(isA<NotAMemberException>()),
        );
        await expectLater(
          endpoints.venue.posterLink(stranger, venue.id!),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
  });
}
