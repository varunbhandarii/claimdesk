import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/item_card.dart';
import 'fixtures.dart';

void main() {
  testWidgets('card shows a short name, zone, age, reference and status', (
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
    expect(find.text('Black backpack'), findsOneWidget);
    expect(find.text('Pool · 2 h'), findsOneWidget);
    expect(find.text('ABC123'), findsOneWidget);
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
    expect(find.text('Captioning'), findsOneWidget);
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
  testWidgets('grid rows share their tallest card height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: CardGrid(
              itemCount: 3,
              minCardWidth: 160,
              itemBuilder: (_, index) => SizedBox(
                key: ValueKey(index),
                height: index == 0 ? 120 : 60,
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey(1))).height,
      tester.getSize(find.byKey(const ValueKey(0))).height,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey(0))).dy),
    );
  });
}
