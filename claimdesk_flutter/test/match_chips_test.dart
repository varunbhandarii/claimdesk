import 'package:claimdesk_flutter/ui/desk_widgets.dart';
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
      expect(find.text('Category differs'), findsOneWidget);
      expect(find.text('Brand differs'), findsOneWidget);
      expect(find.byType(EvidenceLine), findsNWidgets(2));
      expect(
        tester
            .widget<EvidenceLine>(
              find.widgetWithText(EvidenceLine, 'Category differs'),
            )
            .kind,
        Evidence.differs,
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
      expect(find.text('“mark 5”'), findsOneWidget);
      expect(find.text('“mark 6”'), findsNothing);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Colour'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'keyword: 0.80',
        ),
        findsNWidgets(6),
      );
    },
  );
}
