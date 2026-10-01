import 'package:claimdesk_flutter/ui/match_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'match_fixtures.dart';

void main() {
  testWidgets(
    'chips omit missing and low signals and outline explicit disagreements',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchChips(
              explanation: matchExplanation(
                category: 0,
                colour: .49,
                brand: 0,
                zone: null,
                time: null,
                keyword: .49,
              ),
            ),
          ),
        ),
      );
      expect(find.text('category differs'), findsOneWidget);
      expect(find.text('brand differs'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
      expect(
        tester.widget<Chip>(find.widgetWithText(Chip, 'category differs')).side,
        isNot(BorderSide.none),
      );
    },
  );
  testWidgets(
    'stored keywords are capped at six and numeric tooltips are available',
    (tester) async {
      final explanation = matchExplanation().copyWith(
        matchedKeywords: List.generate(8, (i) => 'mark $i'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MatchChips(explanation: explanation)),
        ),
      );
      expect(find.text('keyword: mark 5'), findsOneWidget);
      expect(find.text('keyword: mark 6'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'keyword: 0.80',
        ),
        findsNWidgets(6),
      );
    },
  );
}
