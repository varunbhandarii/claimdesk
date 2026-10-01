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
    Future<Response> call(String path, {Map<String, String>? form}) async =>
        await router(
              RequestInternal.create(
                form == null ? Method.get : Method.post,
                Uri.parse('http://localhost$path'),
                Object(),
                headers: Headers.build(
                  (h) =>
                      h['Content-Type'] = ['application/x-www-form-urlencoded'],
                ),
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
          'filedAt',
          'updatedAt',
          'venue',
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
  });
}
