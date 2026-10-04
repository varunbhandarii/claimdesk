import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/attribute_chips.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'observations show description, colours, brand, marks and privacy',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttributeChips(
              attributes: attributes(category: 'handbag'),
              restricted: true,
            ),
          ),
        ),
      );
      expect(find.text('What the desk sees'), findsOneWidget);
      expect(find.text('A black backpack'), findsOneWidget);
      expect(find.text('Black'), findsOneWidget);
      expect(find.text('Navy'), findsOneWidget);
      expect(find.text('Test brand'), findsOneWidget);
      expect(find.text('Small red patch'), findsOneWidget);
      expect(
        find.text('Staff only — this item is never shown publicly.'),
        findsOneWidget,
      );
      expect(find.text('name'), findsOneWidget);
    },
  );
}
