// Fixture session and screens shared by the accessibility and layout tests.
import 'dart:io';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/app/venue_session.dart';
import 'package:claimdesk_flutter/screens/item_detail_screen.dart';
import 'package:claimdesk_flutter/screens/item_list_screen.dart';
import 'package:claimdesk_flutter/screens/log_item_screen.dart';
import 'package:claimdesk_flutter/screens/match_detail_screen.dart';
import 'package:claimdesk_flutter/screens/release_screen.dart';
import 'package:claimdesk_flutter/screens/report_detail_screen.dart';
import 'package:claimdesk_flutter/ui/desk_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';
import 'match_fixtures.dart';

final zones = [
  Zone(id: venueId, venueId: venueId, name: 'Pool deck', adjacentZoneIds: []),
];
final card = matchCard();
final report = card.report.copyWith(
  status: ReportStatus.possibleMatch,
  createdAt: DateTime(2026, 9, 29, 12),
);
final answers = [
  ReportAnswer(
    venueId: venueId,
    reportId: venueId,
    matchId: itemId,
    question: 'What is inside the main compartment?',
    answer: 'A blue notebook and a water bottle.',
    createdAt: DateTime(2026, 9, 30, 12),
  ),
  ReportAnswer(
    venueId: venueId,
    reportId: venueId,
    matchId: itemId,
    question: 'Where exactly were you when you last had it?',
    answer: 'By the pool deck benches around noon.',
    createdAt: DateTime(2026, 9, 30, 12),
  ),
];
final summary = DeskSummary(
  newMatches: 1,
  captioningFailed: [],
  captioningFailedCount: 0,
  overdue: [item()],
  overdueCount: 1,
  expiringSoon: [],
  expiringSoonCount: 0,
  expired: [],
  expiredCount: 0,
  openReports: 1,
  recent: [item()],
  onShelf: 4,
  returnedThisWeek: 1,
  generatedAt: DateTime(2026, 10, 3, 12),
);

/// Answers every call the main screens make with fixture data.
class FixtureClient extends Client {
  FixtureClient() : super('http://localhost:1/');
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    final Object? result = switch ('$endpoint.$method') {
      'item.getItem' => item(),
      'item.photoUrl' || 'item.findByRefCode' => null,
      'item.history' || 'report.history' => <HistoryEntry>[],
      'item.custody' => <CustodyEvent>[],
      'item.listItems' || 'item.searchItems' => [item()],
      'venue.zones' => zones,
      'match.forItem' || 'match.forReport' || 'match.inbox' => [card],
      'match.answers' => answers,
      'release.releaseRecord' => null,
      'report.getReport' => report,
      'report.listReports' => [report],
      'desk.summary' => summary,
      _ => throw UnimplementedError('$endpoint.$method'),
    };
    return result as T;
  }
}

VenueSession session() {
  final s = VenueSession(
    client: FixtureClient(),
    venue: Venue(id: venueId, name: 'Test desk', slug: 'test-desk'),
    membership: StaffMembership(
      authUserId: venueId,
      venueId: venueId,
      role: StaffRole.supervisor,
      displayName: 'Sam Supervisor',
    ),
    onDenied: () {},
  );
  return s
    ..items = [item()]
    ..reports = [report]
    ..inbox = [card]
    ..summary = summary
    ..zones = zones
    ..loading = false
    ..summaryLoading = false
    ..inboxLoading = false
    ..reportsLoading = false;
}

typedef Screen = ({String name, Widget Function() build, String? tab});

final screens = <Screen>[
  (
    name: 'Desk',
    build: () => ItemListScreen(onSignOut: () async {}, onChangeVenue: () {}),
    tab: null,
  ),
  (
    name: 'Items',
    build: () => ItemListScreen(onSignOut: () async {}, onChangeVenue: () {}),
    tab: 'Items',
  ),
  (
    name: 'Reports',
    build: () => ItemListScreen(onSignOut: () async {}, onChangeVenue: () {}),
    tab: 'Reports',
  ),
  (
    name: 'Inbox',
    build: () => ItemListScreen(onSignOut: () async {}, onChangeVenue: () {}),
    tab: 'Inbox',
  ),
  (
    name: 'Item detail',
    build: () => ItemDetailScreen(itemId: itemId),
    tab: null,
  ),
  (
    name: 'Match review',
    build: () => MatchDetailScreen(matchId: itemId, reportId: venueId),
    tab: null,
  ),
  (
    name: 'Report detail',
    build: () => ReportDetailScreen(reportId: venueId),
    tab: null,
  ),
  (
    name: 'Return to owner',
    build: () => ReleaseScreen(
      item: item(status: ItemStatus.matched),
      matchId: itemId,
      reportRefCode: 'REPORT',
      answers: answers,
      submit: (input, png) async => throw UnimplementedError(),
    ),
    tab: null,
  ),
  (name: 'Log item', build: () => const LogItemScreen(), tab: null),
  (
    name: 'Log item details',
    build: () => const LogItemScreen(),
    tab: 'More details',
  ),
];

/// Roboto from the Flutter SDK stands in for the brand fonts in the layout
/// checks: the default test font draws every glyph a full em wide, so layouts
/// would overflow far sooner than on a device. The contrast check keeps the
/// default font, whose solid glyphs give it clean colours to sample.
const roboto = DeskType(
  display: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w900),
  heading: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700),
  body: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
  strong: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
  mono: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700),
);

Future<void> loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  final loader = FontLoader('Roboto');
  for (final name in ['regular', 'medium', 'bold', 'black']) {
    final file = File('${dir.path}/roboto-$name.ttf');
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
  }
  await loader.load();
}

Future<void> pumpScreen(
  WidgetTester tester,
  Screen screen,
  Brightness brightness, {
  DeskType fonts = DeskType.fallback,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildDeskTheme(brightness, fonts: fonts),
      home: VenueScope(session: session(), child: screen.build()),
    ),
  );
  await tester.pumpAndSettle();
  if (screen.tab != null) {
    if (find.text(screen.tab!).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.text(screen.tab!),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    final target = find.text(screen.tab!).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }
}
