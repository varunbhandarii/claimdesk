import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/status.dart';
import 'package:claimdesk_flutter/ui/match_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'match_fixtures.dart';

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
}
