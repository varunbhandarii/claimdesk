import 'package:claimdesk_flutter/ui/item_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'search debounces for 400ms, ignores one letter and clears immediately',
    (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemSearchField(query: '', onQuery: queries.add, results: 0),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'u');
      await tester.pump(const Duration(milliseconds: 500));
      expect(queries, isEmpty);
      await tester.enterText(find.byType(TextField), 'umbrella');
      await tester.pump(const Duration(milliseconds: 399));
      expect(queries, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(queries, ['umbrella']);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(queries, ['umbrella', '']);
    },
  );
  testWidgets(
    'active query shows result copy and a Desk preset clears pending input',
    (tester) async {
      final queries = <String>[];
      Widget app(String query) => MaterialApp(
        home: Scaffold(
          body: ItemSearchField(query: query, onQuery: queries.add, results: 3),
        ),
      );
      await tester.pumpWidget(app('brolly'));
      expect(find.text('3 results for “brolly”'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'backpack');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(app(''));
      await tester.pump(const Duration(milliseconds: 500));
      expect(queries, isEmpty);
      expect(find.text('backpack'), findsNothing);
    },
  );
}
