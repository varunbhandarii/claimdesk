import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/item_card.dart';
import 'fixtures.dart';

void main() {
  testWidgets('card shows description, zone, reference, age and staff status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item(),
            zoneName: 'Pool',
            now: DateTime(2026, 9, 30, 12),
          ),
        ),
      ),
    );
    expect(find.text('A black backpack'), findsOneWidget);
    expect(find.text('Pool · ABC123'), findsOneWidget);
    expect(find.text('Found 2 h ago'), findsOneWidget);
    expect(find.text('On shelf'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
  testWidgets('restricted and slow captioning items show actionable badges', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item(status: ItemStatus.captioning, restricted: true),
            zoneName: 'Pool',
            now: DateTime(2026, 9, 30, 10, 2),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(
      find.text('Caption is taking longer. Tap to add details.'),
      findsOneWidget,
    );
  });
  testWidgets('failed caption card provides its own message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(item: item(), zoneName: 'Pool', captionFailed: true),
        ),
      ),
    );
    expect(find.text('Caption failed, tap to add details'), findsOneWidget);
  });
}
