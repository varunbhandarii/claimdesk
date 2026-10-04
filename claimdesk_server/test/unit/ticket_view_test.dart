import 'dart:convert';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:claimdesk_server/src/web/public/public_views.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('every ticket state has a safe view and venue-local dates', () {
    final venue = Venue(
      name: 'Desk',
      slug: 'desk',
      timezone: 'America/New_York',
    );
    for (final state in ReportStatus.values) {
      final report = LostReport(
        venueId: UuidValue.fromString(const Uuid().v4()),
        refCode: 'ABC234',
        publicToken: 'private-owner-token',
        rawText: 'Never-public-description',
        colourHints: [],
        status: state,
        contactEmail: 'secret@example.test',
        ownerName: 'Private Person',
        ownerOnlyDetails: 'private-identifying-details',
        createdAt: DateTime.utc(2026, 9, 30, 16),
      );
      final view = TicketView(report, venue);
      final serialized = jsonEncode(view.toMap());
      for (final secret in [
        report.publicToken,
        report.rawText,
        report.contactEmail!,
        report.ownerName!,
        report.ownerOnlyDetails!,
      ]) {
        expect(serialized, isNot(contains(secret)));
        expect(jsonEncode(view.toJson()), isNot(contains(secret)));
      }
      expect(view.sentence, isNotEmpty);
      expect(view.toMap()['filedAt'], 'Sep 30, 2026, 12:00 PM EDT');
      expect(
        (view.toMap()['steps'] as List).where((e) => e['current'] == true),
        hasLength(1),
      );
    }
  });
  test('progress steps follow the claim and a closed report stays short', () {
    final venue = Venue(name: 'Desk', slug: 'desk', timezone: 'Etc/UTC');
    LostReport report(ReportStatus status) => LostReport(
      venueId: UuidValue.fromString(const Uuid().v4()),
      refCode: 'ABC234',
      publicToken: 'token',
      rawText: 'text',
      colourHints: [],
      status: status,
      createdAt: DateTime.utc(2026, 10, 4, 14),
      updatedAt: DateTime.utc(2026, 10, 4, 14),
    );
    final ready = TicketView(report(ReportStatus.readyForPickup), venue);
    final steps = ready.steps;
    expect(steps.map((s) => s['label']), [
      'Received',
      'Searching',
      'Possible match',
      'Ready for pickup',
      'Returned',
    ]);
    expect(steps.map((s) => s['done']), [true, true, true, false, false]);
    expect(steps[3]['current'], true);
    expect(steps[4]['next'], true);
    expect(steps.first['when'], 'Oct 4, 2026, 2:00 PM UTC');
    expect(ready.toMap()['stepNumber'], 4);
    expect(ready.toMap()['compact'], true);
    expect(
      (ready.toMap()['segments'] as List).where((s) => s['on'] == true),
      hasLength(4),
    );
    expect(ready.stampDate(DateTime.utc(2026, 10, 4)), 'OCT 04 2026');
    final closed = TicketView(report(ReportStatus.closed), venue);
    expect(closed.steps.map((s) => s['label']), ['Received', 'Closed']);
    expect(closed.steps.last['current'], true);
    expect(closed.toMap()['compact'], false);
  });
  test('Spanish tickets use Spanish dates, steps and sentences', () {
    final venue = Venue(
      name: 'Desk',
      slug: 'desk',
      timezone: 'America/New_York',
    );
    LostReport report(ReportStatus status) => LostReport(
      venueId: UuidValue.fromString(const Uuid().v4()),
      refCode: 'ABC234',
      publicToken: 'token',
      rawText: 'text',
      colourHints: [],
      status: status,
      createdAt: DateTime.utc(2026, 9, 30, 16),
      updatedAt: DateTime.utc(2026, 10, 4, 1),
      closedAt: DateTime.utc(2026, 11, 29, 17),
    );
    final ready = TicketView(
      report(ReportStatus.readyForPickup),
      venue,
      lang: PublicLang.es,
    );
    expect(
      ready.date(DateTime.utc(2026, 9, 30, 16)),
      '30 sept 2026, 12:00 p. m. EDT',
    );
    expect(
      ready.date(DateTime.utc(2026, 10, 4, 1)),
      '3 oct 2026, 9:00 p. m. EDT',
    );
    expect(
      ready.date(DateTime.utc(2026, 10, 4, 13, 5)),
      '4 oct 2026, 9:05 a. m. EDT',
    );
    expect(ready.stampDate(DateTime.utc(2026, 10, 4, 18)), '04 OCT 2026');
    expect(ready.steps.map((s) => s['label']), [
      'Recibido',
      'Buscando',
      'Posible coincidencia',
      'Listo para recoger',
      'Devuelto',
    ]);
    final map = ready.toMap();
    expect(map['stepText'], 'Paso 4 de 5');
    expect(map['statusLabel'], 'Listo para recoger');
    expect(map['deskHours'], 'Pregunte el horario en el mostrador.');
    expect(
      map['filedLine'],
      'Enviado el 30 sept 2026, 12:00 p. m. EDT · actualizado el 3 oct 2026, 9:00 p. m. EDT',
    );
    expect(ready.sentence, startsWith('Su objeto está listo.'));
    expect(
      TicketView(
        report(ReportStatus.closed),
        venue,
        lang: PublicLang.es,
      ).sentence,
      'Este reporte se cerró el 29 nov 2026, 12:00 p. m. EST sin una coincidencia. '
      'Haga un nuevo reporte si todavía le falta el objeto.',
    );
    expect(
      TicketView.idTypeLabel('drivers_licence', lang: PublicLang.es),
      'Licencia de conducir',
    );
    // The status interface stays English.
    expect(
      ready.toJson()['sentence'],
      'Your item is ready. Bring photo ID to the desk.',
    );
    expect(
      TicketView(
        report(ReportStatus.readyForPickup),
        venue,
      ).toMap()['stepText'],
      'Step 4 of 5',
    );
  });
}
