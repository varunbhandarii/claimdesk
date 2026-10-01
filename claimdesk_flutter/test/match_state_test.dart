import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/status.dart';
import 'package:claimdesk_flutter/ui/match_actions.dart';
import 'package:claimdesk_flutter/app/venue_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'match_fixtures.dart';

class DecisionClient extends Client {
  DecisionClient() : super('http://localhost:8080/');
  UuidValue? rejectedId;
  String? rejectedReason;
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (endpoint != 'match' || method != 'reject') {
      throw StateError('Unexpected request');
    }
    rejectedId = args['matchId'] as UuidValue;
    rejectedReason = args['reason'] as String;
    return matchCard() as T;
  }
}

void main() {
  test('states use staff decision labels', () {
    expect(MatchState.values.map(matchStateLabel), [
      'Proposed',
      'Confirmed',
      'Dismissed',
      'Superseded',
    ]);
  });
  testWidgets(
    'confirmed match offers undo and dismissed match has no actions',
    (tester) async {
      for (final state in [MatchState.confirmed, MatchState.rejected]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MatchActions(
                match: matchCard().match.copyWith(state: state),
              ),
            ),
          ),
        );
        expect(find.text('Confirm'), findsNothing);
        expect(
          find.text('Undo confirmation'),
          state == MatchState.confirmed ? findsOneWidget : findsNothing,
        );
      }
    },
  );
  testWidgets('dismiss dialog requires a nonblank reason', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => askDismissReason(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Give a reason.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
  });
  for (final state in [MatchState.pending, MatchState.confirmed]) {
    testWidgets(
      'submits a $state decision after its scrolling button is disposed',
      (tester) async {
        final client = DecisionClient(), card = matchCard();
        final session = VenueSession(
          client: client,
          venue: Venue(id: card.report.venueId, name: 'Desk', slug: 'desk'),
          membership: StaffMembership(
            venueId: card.report.venueId,
            authUserId: card.report.venueId,
            displayName: 'Staff',
          ),
          onDenied: () {},
        );
        final visible = ValueNotifier(true);
        var changed = 0;
        final label = state == MatchState.confirmed
            ? 'Undo confirmation'
            : 'Dismiss';
        await tester.pumpWidget(
          MaterialApp(
            home: VenueScope(
              session: session,
              child: Scaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: visible,
                  builder: (context, show, child) => show
                      ? MatchActions(
                          match: card.match.copyWith(state: state),
                          onChanged: () => changed++,
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        visible.value = false;
        await tester.pump();
        expect(find.byType(MatchActions), findsNothing);
        await tester.enterText(
          find.byType(TextFormField),
          'Different handle after checking owner details',
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));
        expect(client.rejectedId, card.match.id);
        expect(
          client.rejectedReason,
          'Different handle after checking owner details',
        );
        expect(changed, 1);
        expect(tester.takeException(), isNull);
        session.dispose();
        visible.dispose();
        client.close();
      },
    );
  }
}
