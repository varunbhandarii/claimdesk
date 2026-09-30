import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/attribute_chips.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'attributes roll up category and show colours, marks and privacy',
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
      expect(find.text('Bags'), findsOneWidget);
      expect(find.text('black'), findsOneWidget);
      expect(find.text('navy'), findsOneWidget);
      expect(find.text('• Small red patch'), findsOneWidget);
      expect(
        find.text('Staff only — this item is never shown publicly.'),
        findsOneWidget,
      );
      expect(find.text('name'), findsOneWidget);
    },
  );
}
