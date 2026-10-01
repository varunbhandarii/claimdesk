import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/public_page.dart';
import 'package:claimdesk_server/src/web/public/public_views.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() => templates.loadAll(Directory('web/templates')));
  test('public templates render labels and escaped round-trip input', () async {
    final venue = Venue(name: 'Test venue', slug: 'test-venue');
    final values = FormView.of(
      venue,
      [],
      fields: {'rawText': '<script>alert(1)</script>'},
      errors: {'rawText': 'Write more words.'},
    );
    final html = await (await PublicPage.html(
      'lost_form',
      values,
      status: 422,
    )).readAsString();
    expect(html, contains('Check these fields'));
    expect(html, contains('Send my report'));
    expect(html, contains('&lt;script&gt;'));
    expect(html, isNot(contains('<script>')));
    expect(html, isNot(contains('{{')));
    for (final page in [
      'venue',
      'ticket',
      'not_found',
      'rate_limited',
      'unavailable',
    ]) {
      final body = await (await PublicPage.html(
        page,
        VenueView.of(venue),
      )).readAsString();
      expect(body, contains('Powered by ClaimDesk'));
      expect(body, isNot(contains('{{')));
    }
  });
}
