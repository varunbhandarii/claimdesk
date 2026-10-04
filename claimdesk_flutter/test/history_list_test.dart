import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('history sorts, collapses to three and expands safe details', (
    tester,
  ) async {
    final entries = List.generate(
      4,
      (n) => HistoryEntry(
        at: DateTime(2026, 1, 1, n),
        kind: ['audit', 'caption', 'custody', 'release'][n],
        action: 'action',
        summary: 'Entry $n',
        actor: n == 1 ? 'System' : 'Alex',
        data: n == 3 ? {'idTypeSeen': 'Passport'} : {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: HistoryList(entries: entries)),
        ),
      ),
    );
    expect(find.text('Entry 0'), findsNothing);
    expect(find.text('Entry 3'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Entry 3')).dy,
      lessThan(tester.getTopLeft(find.text('Entry 2')).dy),
    );
    await tester.tap(find.text('Show details'));
    await tester.pumpAndSettle();
    expect(find.text('Passport'), findsOneWidget);
    await tester.tap(find.text('Show all 4'));
    await tester.pumpAndSettle();
    expect(find.text('Entry 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
