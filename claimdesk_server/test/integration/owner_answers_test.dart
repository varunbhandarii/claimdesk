@Tags(['integration'])
library;

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/public_intake_service.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Owner verification answers', (builder, endpoints) {
    test(
      'Confirmed answers replace atomically, inherit venue and stay out of list payloads',
      () async {
        final s = builder.build();
        final venue = await makeVenue(s);
        await StaffMembership.db.insertRow(
          s,
          StaffMembership(
            venueId: venue.id!,
            authUserId: actorId,
            displayName: 'Staff',
          ),
        );
        final member = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            actorId.uuid,
            {},
          ),
        );
        final item = await makeItem(s, venue.id!);
        var report = await makeReport(s, venue.id!);
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(
            status: ReportStatus.possibleMatch,
            categoryHint: 'umbrella',
          ),
        );
        var match = await makeMatch(s, item, report);
        match = await ItemMatch.db.updateRow(
          s,
          match.copyWith(state: MatchState.confirmed),
        );
        final service = PublicIntakeService();
        expect(
          await service.answer(s, report, [
            '  A small chip at the tip  ',
            'Reception at around noon',
          ]),
          isTrue,
        );
        expect(
          await service.answer(s, report, [
            'A leather loop on the handle',
            'Reception at about one',
          ]),
          isTrue,
        );
        final rows = await endpoints.match.answers(member, match.id!);
        expect(rows, hasLength(2));
        expect(rows.every((a) => a.venueId == report.venueId), isTrue);
        expect(
          rows.map((a) => a.answer),
          contains('A leather loop on the handle'),
        );
        final audits = await AuditEvent.db.find(
          s,
          where: (t) =>
              t.entityId.equals(report.id!) & t.action.equals('answered'),
        );
        expect(audits, hasLength(2));
        expect(audits.toString(), isNot(contains('leather loop')));
        final cards = await endpoints.match.forReport(member, report.id!);
        expect(cards.toString(), isNot(contains('leather loop')));
        await expectLater(
          endpoints.match.answers(builder, match.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(status: ReportStatus.returned),
        );
        expect(
          await service.answer(s, report, [
            'A leather loop on the handle',
            'Reception at about one',
          ]),
          isFalse,
        );
        expect(
          await ReportAnswer.db.count(
            s,
            where: (t) => t.matchId.equals(match.id!),
          ),
          2,
        );
      },
    );
  });
}
