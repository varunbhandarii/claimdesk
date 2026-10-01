import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/owner_answers.dart';
import 'package:claimdesk_flutter/ui/match_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';
import 'match_fixtures.dart';

void main() {
  testWidgets('Owner evidence and answer time replace the waiting message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OwnerAnswers(
            answers: const [],
            postedAt: DateTime(2026, 10, 1),
          ),
        ),
      ),
    );
    expect(find.textContaining('Not answered yet'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OwnerAnswers(
            answers: [
              ReportAnswer(
                venueId: venueId,
                reportId: itemId,
                matchId: itemId,
                question: 'What was inside?',
                answer: 'A fictional blue notebook',
                createdAt: DateTime(2026, 10, 1, 12),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('What was inside?'), findsOneWidget);
    expect(find.text('A fictional blue notebook'), findsOneWidget);
    expect(find.textContaining('Answered 2026'), findsOneWidget);
    expect(find.textContaining('Not answered yet'), findsNothing);
  });
  testWidgets('Pickup actions appear only before a permanent release', (
    tester,
  ) async {
    for (final released in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchActions(
              match: matchCard().match.copyWith(state: MatchState.confirmed),
              reportStatus: released
                  ? ReportStatus.returned
                  : ReportStatus.possibleMatch,
              onRelease: () {},
              releasedAt: released ? DateTime(2026, 10, 1) : null,
            ),
          ),
        ),
      );
      for (final label in [
        'Mark ready for pickup',
        'Release item',
        'Undo confirmation',
      ]) {
        expect(find.text(label), released ? findsNothing : findsOneWidget);
      }
      if (released) expect(find.textContaining('Released on'), findsOneWidget);
    }
  });
}
