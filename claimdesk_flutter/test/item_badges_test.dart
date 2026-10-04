import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/item_badges.dart';
import 'package:claimdesk_flutter/ui/pills.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'handoff and hold badges cover exact boundaries and hide terminal states',
    (tester) async {
      final now = DateTime(2026, 10, 3, 12);
      Future<void> render(FoundItem value) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemBadges(item: value, now: now),
          ),
        ),
      );
      await render(
        item().copyWith(
          handoffDueAt: now.subtract(const Duration(microseconds: 1)),
        ),
      );
      expect(find.text('Police hand-off overdue'), findsOneWidget);
      expect(
        tester.widget<StatusPill>(find.byType(StatusPill)).tone,
        Tone.bad,
      );
      await render(
        item().copyWith(
          handoffDueAt: now.add(const Duration(days: 3)),
          holdUntil: now,
        ),
      );
      expect(find.textContaining('Hand to police by'), findsOneWidget);
      expect(find.textContaining('Hold ends'), findsOneWidget);
      await render(
        item().copyWith(
          handoffDueAt: now.add(const Duration(days: 3, microseconds: 1)),
        ),
      );
      expect(find.byType(StatusPill), findsNothing);
      for (final status in [
        ItemStatus.claimed,
        ItemStatus.transferred,
        ItemStatus.disposed,
      ]) {
        await render(
          item(
            status: status,
          ).copyWith(handoffDueAt: now.subtract(const Duration(days: 1))),
        );
        expect(find.byType(StatusPill), findsNothing);
      }
    },
  );
}
