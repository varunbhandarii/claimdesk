import 'package:claimdesk_flutter/ui/tag_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'print prepares an expiring link then a user tap opens the browser',
    (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagButton(
              link: () async => 'https://example.test/tag/demo',
              open: (url) async {
                opened.add(url);
                return true;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Print tag'));
      await tester.pumpAndSettle();
      expect(find.text('Printable tag ready'), findsOneWidget);
      expect(opened, isEmpty);
      await tester.tap(find.text('Open tag'));
      await tester.pumpAndSettle();
      expect(opened, ['https://example.test/tag/demo']);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
