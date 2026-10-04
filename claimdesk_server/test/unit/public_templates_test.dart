import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:claimdesk_server/src/web/public/public_page.dart';
import 'package:claimdesk_server/src/web/public/public_views.dart';
import 'package:claimdesk_server/src/web/public/report_form_input.dart';
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
  test('every page renders in Spanish with a switch back to English', () async {
    final venue = Venue(name: 'Test venue', slug: 'test-venue');
    const spanish = PublicLocale(
      PublicLang.es,
      chosen: true,
      switchable: true,
    );
    const english = [
      'Skip to content',
      'Lost &amp; found desk',
      'Powered by',
      'Lost something?',
      'Report a lost item',
      'Desk hours',
      'Picking up an item',
      'Check these fields',
      'Send my report',
      'Not sure',
      'Your claim ticket',
      'Quote this code',
      'Bring photo ID',
      'Keep this link private',
      'Filed ',
      'No ticket or venue here',
      'Please try again',
      'We could not complete',
    ];
    Future<String> render(String page, Map<String, dynamic> values) async {
      final response = await PublicPage.html(page, values, locale: spanish);
      expect(response.headers['content-language'], ['es']);
      expect(response.headers['vary'], ['Accept-Language']);
      final html = await response.readAsString();
      expect(html, contains('<html lang="es">'), reason: page);
      expect(html, contains('hreflang="en"'), reason: page);
      expect(html, contains('>English</a>'), reason: page);
      expect(html, isNot(contains('{{')), reason: page);
      for (final text in english) {
        expect(html, isNot(contains(text)), reason: '$page: $text');
      }
      return html;
    }

    final venuePage = await render(
      'venue',
      VenueView.of(venue, lang: PublicLang.es),
    );
    expect(venuePage, contains('¿Perdió algo?'));
    expect(
      venuePage,
      contains('href="&#x2F;v&#x2F;test-venue&#x2F;lost?lang=es"'),
    );
    final parsed = ReportFormInput.parse(
      {'rawText': 'corto', 'contactEmail': 'mal'},
      zones: const [],
      now: DateTime.utc(2026, 10, 4, 12),
      timezone: 'America/New_York',
      lang: PublicLang.es,
    );
    final form = await render(
      'lost_form',
      FormView.of(
        venue,
        [],
        fields: {'rawText': 'corto'},
        errors: parsed.errors,
        lang: PublicLang.es,
      ),
    );
    expect(form, contains('Revise estos campos'));
    expect(form, contains('Escriba un correo electrónico válido.'));
    expect(form, contains('Paraguas e impermeables'));
    expect(form, contains('Azul marino'));
    expect(form, contains('<input type="hidden" name="lang" value="es">'));
    expect(await render('not_found', {}), contains('Aquí no hay ningún'));
    expect(
      await render('rate_limited', {'rateBody': 'Espere 30 segundos.'}),
      contains('Espere 30 segundos.'),
    );
    expect(await render('unavailable', {}), contains('No pudimos completar'));
    for (final state in ReportStatus.values) {
      final report = LostReport(
        venueId: UuidValue.fromString(const Uuid().v4()),
        refCode: 'ABC234',
        publicToken: 'private-owner-token',
        rawText: 'Never-public-description',
        colourHints: [],
        status: state,
      );
      final view = TicketView(report, venue, lang: PublicLang.es);
      final html = await render('ticket', {
        ...view.toMap(),
        'answered': state == ReportStatus.readyForPickup,
        'photo': state == ReportStatus.readyForPickup,
        'photoPath': '/t/private-owner-token/photo',
        'receipt': state == ReportStatus.returned
            ? {
                'returnedAt': view.date(DateTime.utc(2026, 10, 4, 18)),
                'idTypeSeen': TicketView.idTypeLabel(
                  'passport',
                  lang: PublicLang.es,
                ),
              }
            : null,
        'stampDate': view.stampDate(DateTime.utc(2026, 10, 4, 18)),
        'answerForm': state == ReportStatus.possibleMatch,
        'questions': [
          {'field': 'answer1', 'question': '¿Primera?', 'value': ''},
          {'field': 'answer2', 'question': '¿Segunda?', 'value': ''},
        ],
      });
      expect(html, contains(view.labels[state.index]), reason: state.name);
      expect(html, contains('ABC234'));
    }
  });
}
