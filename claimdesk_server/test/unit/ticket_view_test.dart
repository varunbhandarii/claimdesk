import 'dart:convert';
import 'package:claimdesk_server/src/generated/protocol.dart';
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
      expect(view.toMap()['filedAt'], contains('12:00 EDT'));
      expect(
        (view.toMap()['steps'] as List).where((e) => e['current'] == true),
        hasLength(1),
      );
    }
  });
}
