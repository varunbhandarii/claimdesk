import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  testWidgets('report card shows hints and age but no contact or credential', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportCard(
            report: LostReport(
              venueId: venueId,
              refCode: 'ABC234',
              publicToken: 'private-token',
              rawText: 'My black folding umbrella',
              categoryHint: 'umbrella',
              colourHints: ['black'],
              contactEmail: 'private@example.test',
              ownerOnlyDetails: 'inside-only-mark',
              createdAt: DateTime(2026, 9, 30, 10),
            ),
            zoneName: 'Pool',
            now: DateTime(2026, 9, 30, 13),
          ),
        ),
      ),
    );
    expect(find.text('ABC234'), findsOneWidget);
    expect(
      find.text('Umbrellas & rain gear · Pool · filed 3 h ago'),
      findsOneWidget,
    );
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('My black folding umbrella'), findsOneWidget);
    expect(find.bySemanticsLabel('Black'), findsOneWidget);
    expect(find.text('private@example.test'), findsNothing);
    expect(find.text('private-token'), findsNothing);
    expect(find.text('inside-only-mark'), findsNothing);
  });
}
