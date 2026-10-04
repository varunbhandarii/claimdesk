import 'package:claimdesk_flutter/ui/match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'match_fixtures.dart';

void main() {
  for (final version in ['v1-draft', 'v1']) {
    testWidgets(
      '$version displays Preliminary only while refinement is pending',
      (tester) async {
        final card = matchCard();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MatchCardTile(
                card: card.copyWith(
                  match: card.match.copyWith(algorithmVersion: version),
                ),
              ),
            ),
          ),
        );
        expect(
          find.text('Preliminary'),
          version.endsWith('-draft') ? findsOneWidget : findsNothing,
        );
      },
    );
  }
  testWidgets(
    'card shows both references, score, leader and stored readable keywords',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MatchCardTile(card: matchCard())),
        ),
      );
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('REPORT'), findsOneWidget);
      expect(find.text('“My black bag”'), findsOneWidget);
      expect(find.text('Strong · 0.82'), findsOneWidget);
      expect(find.text('Clear leader'), findsOneWidget);
      expect(find.text('“wooden handle”'), findsOneWidget);
      expect(find.text('Found 1 day after lost'), findsOneWidget);
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
    expect(find.text('Black backpack'), findsNothing);
    expect(find.text('Restricted item'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
