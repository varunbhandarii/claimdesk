import 'dart:io';
import 'dart:convert';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/venue_page_route.dart';
import 'package:claimdesk_server/src/web/public/lost_form_route.dart';
import 'package:claimdesk_server/src/web/public/ticket_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Public route handlers', (builder, _) {
    late RelicRouter router;
    late Session s;
    setUp(() async {
      s = builder.build();
      await makeVenue(s, slug: 'test-desk');
      await templates.loadAll(Directory('web/templates'));
      router = RelicRouter();
      router.get('/v/:slug', (req) => VenuePageRoute().handleCall(s, req));
      final form = LostFormRoute(
        salt: 'test-only-salt-32-characters-long',
        trustProxy: false,
      );
      router.anyOf(
        {Method.get, Method.post},
        '/v/:slug/lost',
        (req) => form.handleCall(s, req),
      );
      router.get('/t/:token', (req) => TicketRoute().handleCall(s, req));
      router.get(
        '/t/:token/status.json',
        (req) => TicketJsonRoute().handleCall(s, req),
      );
    });
    Future<Response> call(
      String path, {
      Map<String, String>? form,
      String? language,
    }) async =>
        await router(
              RequestInternal.create(
                form == null ? Method.get : Method.post,
                Uri.parse('http://localhost$path'),
                Object(),
                headers: Headers.build((h) {
                  h['Content-Type'] = ['application/x-www-form-urlencoded'];
                  if (language != null) h['Accept-Language'] = [language];
                }),
                body: form == null
                    ? Body.empty()
                    : Body.fromString(Uri(queryParameters: form).query),
              ),
            )
            as Response;
    test(
      'venue and form render, methods and malformed paths are refused',
      () async {
        expect((await call('/v/test-desk')).statusCode, 200);
        expect((await call('/v/unknown-desk')).statusCode, 404);
        expect((await call('/v/test-desk/lost')).statusCode, 200);
        expect((await call('/v/test-desk', form: {})).statusCode, 405);
        expect((await call('/t/invalid')).statusCode, 404);
        expect((await call('/t/invalid/status.json')).statusCode, 404);
      },
    );
    test(
      'valid submission redirects to a private safe ticket and JSON',
      () async {
        final response = await call(
          '/v/test-desk/lost',
          form: {
            'rawText': 'My black folding umbrella with a wooden handle',
            'unsureDay': 'on',
            'contactEmail': 'owner@example.test',
            'ownerName': 'Private person',
            'ownerOnlyDetails': 'Private identifying mark',
            'consent': 'on',
          },
        );
        expect(response.statusCode, 303);
        final path = response.headers['location']!.single;
        final ticket = await call(path);
        expect(ticket.statusCode, 200);
        expect(ticket.headers['cache-control'], ['no-store']);
        expect(ticket.headers['x-robots-tag'], ['noindex']);
        final html = await ticket.readAsString();
        expect(html, contains('Received'));
        for (final secret in [
          'owner@example.test',
          'Private person',
          'Private identifying mark',
          'My black folding umbrella',
        ]) {
          expect(html, isNot(contains(secret)));
        }
        final data =
            jsonDecode(await (await call('$path/status.json')).readAsString())
                as Map;
        expect(data.keys.toSet(), {
          'refCode',
          'status',
          'sentence',
          'filedAt',
          'updatedAt',
          'venue',
          'answered',
        });
        expect(data['status'], 'received');
        expect(await LostReport.db.count(s), 1);
      },
    );
    test(
      'invalid fields round-trip escaped text and honeypot stores nothing',
      () async {
        final bad = await call(
          '/v/test-desk/lost',
          form: {'rawText': '<script>bad</script>', 'contactEmail': 'wrong'},
        );
        expect(bad.statusCode, 422);
        final html = await bad.readAsString();
        expect(html, contains('Check these fields'));
        expect(html, contains('&lt;script&gt;'));
        expect(html, contains('value="wrong"'));
        final bot = await call('/v/test-desk/lost', form: {'website': 'spam'});
        expect(bot.statusCode, 303);
        expect((await call(bot.headers['location']!.single)).statusCode, 404);
        expect(await LostReport.db.count(s), 0);
      },
    );
    test(
      'Spanish follows the visitor through the form, redirect and ticket',
      () async {
        final venue = await call('/v/test-desk?lang=es');
        expect(venue.headers['content-language'], ['es']);
        expect(venue.headers['vary'], ['Accept-Language']);
        final venueHtml = await venue.readAsString();
        expect(venueHtml, contains('<html lang="es">'));
        expect(venueHtml, contains('¿Perdió algo?'));
        expect(
          venueHtml,
          contains('href="&#x2F;v&#x2F;test-desk&#x2F;lost?lang=es"'),
        );
        expect(venueHtml, contains('href="?lang=en" lang="en"'));

        final browser = await call('/v/test-desk/lost', language: 'es-US,es');
        final formHtml = await browser.readAsString();
        expect(formHtml, contains('Reportar un objeto perdido'));
        expect(
          formHtml,
          contains('<input type="hidden" name="lang" value="es">'),
        );
        final english = await (await call(
          '/v/test-desk/lost',
          language: 'en-US',
        )).readAsString();
        expect(english, contains('Report a lost item'));
        expect(english, isNot(contains('name="lang"')));
        expect(english, contains('>Español</a>'));

        final bad = await call(
          '/v/test-desk/lost',
          form: {'lang': 'es', 'rawText': 'corto', 'contactEmail': 'mal'},
        );
        expect(bad.statusCode, 422);
        final badHtml = await bad.readAsString();
        expect(badHtml, contains('Escriba un correo electrónico válido.'));
        expect(badHtml, contains('Revise estos campos'));

        final sent = await call(
          '/v/test-desk/lost',
          form: {
            'lang': 'es',
            'rawText': 'Mi paraguas negro plegable con mango de madera',
            'unsureDay': 'on',
            'contactEmail': 'owner@example.test',
            'consent': 'on',
          },
        );
        expect(sent.statusCode, 303);
        final location = sent.headers['location']!.single;
        expect(location, endsWith('?lang=es'));
        final ticketHtml = await (await call(location)).readAsString();
        expect(ticketHtml, contains('Su comprobante'));
        expect(ticketHtml, contains('Recibido'));
        expect(ticketHtml, contains('href="&#x2F;v&#x2F;test-desk?lang=es"'));
        expect(ticketHtml, isNot(contains('Mi paraguas negro')));
        final data =
            jsonDecode(
                  await (await call(
                    '${Uri.parse(location).path}/status.json',
                  )).readAsString(),
                )
                as Map;
        expect(data['sentence'], startsWith('We have your report.'));
        final report = await LostReport.db.findFirstRow(s);
        expect(
          report!.rawText,
          'Mi paraguas negro plegable con mango de madera',
        );

        final missing = await call('/v/unknown-desk?lang=es');
        expect(missing.statusCode, 404);
        expect(await missing.readAsString(), contains('Aquí no hay'));
        final bot = await call(
          '/v/test-desk/lost',
          form: {'lang': 'es', 'website': 'spam'},
        );
        expect(bot.headers['location']!.single, endsWith('?lang=es'));
        final decoy = await call(bot.headers['location']!.single);
        expect(decoy.statusCode, 404);
        expect(await decoy.readAsString(), contains('Aquí no hay'));
      },
    );
  });
}
