@Tags(['http'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  final enabled = Platform.environment['RUN_PUBLIC_HTTP'] == 'true';
  final base = Uri.parse(
    Platform.environment['PUBLIC_WEB_URL'] ?? 'http://localhost:8082',
  );
  final transport = HttpClient();
  Future<({int status, Map<String, List<String>> headers, String body})>
  request(String path, {Map<String, String>? form}) async {
    final req = await transport.openUrl(
      form == null ? 'GET' : 'POST',
      base.resolve(path),
    );
    req.followRedirects = false;
    if (form != null) {
      req.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      req.write(Uri(queryParameters: form).query);
    }
    final response = await req.close();
    final headers = <String, List<String>>{};
    response.headers.forEach((name, values) => headers[name] = values);
    return (
      status: response.statusCode,
      headers: headers,
      body: await utf8.decoder.bind(response).join(),
    );
  }

  tearDownAll(() => transport.close(force: true));
  test(
    'public owner flow, duplicate, safe ticket JSON and invalid form',
    () async {
      final venue = await request('/v/hawrys-demo');
      expect(venue.status, 200);
      expect(venue.body, contains('/v/hawrys-demo/lost'));
      expect((await request('/v/unknown-venue')).status, 404);
      expect((await request('/v/hawrys-demo/lost')).status, 200);
      final nonce = DateTime.now().microsecondsSinceEpoch;
      final form = {
        'rawText': 'A black folding umbrella with a wooden handle',
        'categoryHint': 'umbrella',
        'unsureDay': 'on',
        'contactEmail': 'http-$nonce@example.test',
        'ownerName': 'Fictional HTTP tester',
        'ownerOnlyDetails': 'Private specimen mark',
        'consent': 'on',
      };
      final created = await request('/v/hawrys-demo/lost', form: form);
      expect(created.status, 303);
      final location = created.headers['location']!.single;
      final ticket = await request(location);
      expect(ticket.status, 200);
      expect(ticket.headers['cache-control'], contains('no-store'));
      expect(ticket.headers['x-robots-tag'], contains('noindex'));
      expect(ticket.body, contains('Received'));
      for (final private in [
        form['contactEmail']!,
        form['ownerName']!,
        form['ownerOnlyDetails']!,
        form['rawText']!,
      ]) {
        expect(ticket.body, isNot(contains(private)));
      }
      final json = await request('$location/status.json');
      final data = jsonDecode(json.body) as Map;
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
      expect(ticket.body, contains(data['refCode']));
      final duplicate = await request('/v/hawrys-demo/lost', form: form);
      expect(duplicate.status, 303);
      expect(
        duplicate.headers['location']!.single,
        startsWith('$location?existing=1'),
      );
      final bad = await request(
        '/v/hawrys-demo/lost',
        form: {'rawText': 'bad', 'contactEmail': 'wrong'},
      );
      expect(bad.status, 422);
      expect(bad.body, contains('Check these fields'));
      expect(bad.body, contains('value="wrong"'));
      final bot = await request(
        '/v/hawrys-demo/lost',
        form: {'website': 'filled'},
      );
      expect(bot.status, 303);
      expect((await request(bot.headers['location']!.single)).status, 404);
      expect((await request('/t/unknown-token')).status, 404);
      expect((await request('/t/unknown-token/status.json')).status, 404);
      expect((await request('/robots.txt')).body, contains('Disallow: /t/'));
    },
    skip: !enabled,
  );
  test('eleventh POST is limited with Retry-After', () async {
    // Previous flow uses four POSTs; continue until this address's window fills.
    var blocked = false;
    for (var i = 0; i < 11; i++) {
      final response = await request(
        '/v/hawrys-demo/lost',
        form: {'website': 'filled'},
      );
      if (response.status == 429) {
        expect(
          int.parse(response.headers['retry-after']!.single),
          greaterThan(0),
        );
        blocked = true;
        break;
      }
      expect(response.status, 303);
    }
    expect(blocked, isTrue);
  }, skip: !enabled);
}
