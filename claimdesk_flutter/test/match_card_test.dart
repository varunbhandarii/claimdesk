import 'package:claimdesk_flutter/ui/match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'match_fixtures.dart';

void main() {
  testWidgets(
    'card shows both references, score, leader and stored readable keywords',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MatchCardTile(card: matchCard())),
        ),
      );
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('Report REPORT'), findsOneWidget);
      expect(find.text('Strong · 0.82'), findsOneWidget);
      expect(find.text('Clear leader'), findsOneWidget);
      expect(find.text('keyword: wooden handle'), findsOneWidget);
      expect(find.text('found 1 day after lost'), findsOneWidget);
    },
  );
  testWidgets('restricted card hides item description and shows lock', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MatchCardTile(card: matchCard(restricted: true))),
      ),
    );
    expect(find.text('Black bag with a patch'), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
