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
  test('each ticket state renders its own panel', () async {
    final venue = Venue(
      name: 'Test venue',
      slug: 'test-venue',
      deskHours: 'Daily 9–5',
      pickupInstructions: 'Front desk',
    );
    final expected = {
      ReportStatus.received: 'We have your report.',
      ReportStatus.searching: 'we keep checking as new items arrive',
      ReportStatus.possibleMatch: 'The desk may have your item.',
      ReportStatus.readyForPickup: 'Your item is ready.',
      ReportStatus.returned: 'Back with you. Thank you.',
      ReportStatus.closed: 'File a new report',
    };
    for (final state in ReportStatus.values) {
      final report = LostReport(
        venueId: UuidValue.fromString(const Uuid().v4()),
        refCode: 'ABC234',
        publicToken: 'private-owner-token',
        rawText: 'Never-public-description',
        colourHints: [],
        status: state,
      );
      final html = await (await PublicPage.html('ticket', {
        ...TicketView(report, venue).toMap(),
        'answered': false,
        'photo': state == ReportStatus.readyForPickup,
        'photoPath': '/t/private-owner-token/photo',
        'receipt': state == ReportStatus.returned
            ? {
                'returnedAt': 'Oct 4, 2026, 2:00 PM EDT',
                'idTypeSeen': 'Passport',
              }
            : null,
        'stampDate': 'OCT 04 2026',
        'answerForm': state == ReportStatus.possibleMatch,
        'questions': [
          {'field': 'answer1', 'question': 'First?', 'value': ''},
          {'field': 'answer2', 'question': 'Second?', 'value': ''},
        ],
      }, noStore: true)).readAsString();
      expect(html, contains(expected[state]), reason: state.name);
      expect(html, contains('ABC234'));
      expect(html, isNot(contains('{{')));
      expect(html, isNot(contains('Never-public-description')));
      expect(
        html.contains('Item ready for pickup'),
        state == ReportStatus.readyForPickup,
      );
      expect(
        html.contains('Return receipt'),
        state == ReportStatus.returned,
      );
      expect(
        html.contains('Send answers'),
        state == ReportStatus.possibleMatch,
      );
      expect(
        html.contains('aria-current="step"'),
        state != ReportStatus.possibleMatch &&
            state != ReportStatus.readyForPickup &&
            state != ReportStatus.returned,
      );
    }
  });
}
