import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/transfer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'terminal warning, reference and explicit confirmation survive the sheet',
    (tester) async {
      TransferInput? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showModalBottomSheet<TransferInput>(
                    context: ctx,
                    isScrollControlled: true,
                    builder: (_) => const TransferSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Police · leaves the venue').last);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('This item leaves the venue.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).first, 'POL-24');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('Hand this item over?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result!.toLocation, 'police');
      expect(result!.reference, 'POL-24');
      expect(tester.takeException(), isNull);
    },
  );
}
