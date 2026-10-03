import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/screens/desk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

DeskSummary summary({bool empty = false}) => DeskSummary(
  newMatches: empty ? 0 : 7,
  captioningFailed: [],
  captioningFailedCount: 0,
  overdue: empty ? [] : [item()],
  overdueCount: empty ? 0 : 9,
  expiringSoon: [],
  expiringSoonCount: 0,
  expired: [],
  expiredCount: 0,
  openReports: empty ? 0 : 3,
  recent: empty ? [] : [item()],
  onShelf: 12,
  returnedThisWeek: 2,
  generatedAt: DateTime(2026, 10, 3, 12),
);

void main() {
  testWidgets(
    'desk shows uncapped counts and a tap supplies the matching preset',
    (tester) async {
      String? attention;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeskScreen(
              venueName: 'Demo desk',
              summary: summary(),
              loading: false,
              error: null,
              onRefresh: () async {},
              onItems: (a, status) => attention = a,
              onInbox: () {},
              onReports: () {},
              onItem: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Demo desk'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Overdue hand-offs'), 300);
      await tester.tap(find.text('Overdue hand-offs'));
      expect(attention, 'overdue');
      expect(find.text('9 total, showing 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty attention sections stay visible with their empty copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeskScreen(
            venueName: 'Empty desk',
            summary: summary(empty: true),
            loading: false,
            error: null,
            onRefresh: () async {},
            onItems: (_, _) {},
            onInbox: () {},
            onReports: () {},
            onItem: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Nothing needs attention'), findsWidgets);
    expect(find.text('Captioning failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
