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
              summary: summary(),
              loading: false,
              error: null,
              now: DateTime(2026, 10, 3, 12),
              onRefresh: () async {},
              onItems: (a, status) => attention = a,
              onInbox: () {},
              onReports: () {},
              onItem: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Saturday, October 3'.toUpperCase()), findsOneWidget);
      expect(find.text('Two things need you.'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Overdue hand-offs'), 300);
      await tester.tap(find.text('Overdue hand-offs'));
      expect(attention, 'overdue');
      await tester.scrollUntilVisible(find.text('Showing 1 of 9'), 300);
      expect(find.text('See all 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty attention groups are listed as all clear', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeskScreen(
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
    expect(find.text('Nothing needs you right now.'), findsOneWidget);
    expect(find.textContaining('No matches waiting'), findsOneWidget);
    for (final line in [
      'No overdue police hand-offs',
      'Nothing waiting for disposal',
      'Nothing expiring in the next three days',
      'No failed captions',
    ]) {
      await tester.scrollUntilVisible(find.text(line), 200);
      expect(find.text(line), findsOneWidget);
    }
    expect(find.text('Captioning failed'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('headline counts the groups that need attention', () {
    expect(deskHeadline(0), 'Nothing needs you right now.');
    expect(deskHeadline(1), 'One thing needs you.');
    expect(deskHeadline(2), 'Two things need you.');
    expect(deskHeadline(5), 'Five things need you.');
  });
}
