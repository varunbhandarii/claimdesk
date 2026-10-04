import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/desk_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

List<String> values(List<PopupMenuEntry<String>> entries) => [
  for (final entry in entries.whereType<PopupMenuItem<String>>()) entry.value!,
];

void main() {
  final staff = StaffMembership(
    authUserId: venueId,
    venueId: venueId,
    displayName: 'Staff',
  );

  test('only supervisors see the export and poster entries', () {
    expect(values(deskMenuItems(staff)), ['venue', 'out']);
    expect(
      values(deskMenuItems(staff.copyWith(role: StaffRole.supervisor))),
      ['export', 'poster', 'venue', 'out'],
    );
    expect(values(deskMenuItems(staff, venue: false)), ['out']);
  });

  testWidgets('the poster dialog opens the link on a second tap', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPosterDialog(
                context,
                () async => 'https://desk.example/v/test-desk/poster',
                open: (url) async {
                  opened.add(url);
                  return true;
                },
              ),
              child: const Text('Poster'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Poster'));
    await tester.pumpAndSettle();
    expect(find.text('Venue poster'), findsOneWidget);
    expect(opened, isEmpty);
    await tester.tap(find.text('Open poster'));
    await tester.pumpAndSettle();
    expect(opened, ['https://desk.example/v/test-desk/poster']);
  });

  testWidgets('a refused link shows the error instead of the dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPosterDialog(
                context,
                () async => throw NotAMemberException(
                  message: 'Supervisor role required',
                  venueId: venueId,
                ),
              ),
              child: const Text('Poster'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Poster'));
    await tester.pumpAndSettle();
    expect(find.text('Venue poster'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
