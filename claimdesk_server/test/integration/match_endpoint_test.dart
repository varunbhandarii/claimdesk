@Tags(['integration'])
library;

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Staff matching decisions', (builder, endpoints) {
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    late Session s;
    late Venue venue;
    late FoundItem item;
    late LostReport report;
    late ItemMatch match;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s, slug: 'match-${const Uuid().v4()}');
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Staff',
        ),
      );
      item = await makeItem(s, venue.id!, embedding: unitVector(1, 0));
      item = await FoundItem.db.updateRow(
        s,
        item.copyWith(status: ItemStatus.unclaimed),
      );
      report = await makeReport(s, venue.id!);
      report = await LostReport.db.updateRow(
        s,
        report.copyWith(
          status: ReportStatus.searching,
          embedding: unitVector(1, 0),
          ipHash: 'private',
        ),
      );
      match = await makeMatch(s, item, report);
    });
    tearDown(() async {
      await AuditEvent.db.deleteWhere(
        s,
        where: (t) => t.venueId.equals(venue.id!),
      );
      await Venue.db.deleteRow(s, venue);
    });
    Future<List<ItemMatch>> competitors() async {
      final otherItem = await makeItem(s, venue.id!, refCode: 'ITEM02');
      final otherReport = await makeReport(
        s,
        venue.id!,
        refCode: 'REPORT02',
        publicToken: 'other',
      );
      return [
        await makeMatch(s, otherItem, report),
        await makeMatch(s, item, otherReport),
      ];
    }

    test('every method requires membership and login', () async {
      final outsider = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          const Uuid().v4(),
          {},
        ),
      );
      for (final caller in [outsider, builder]) {
        final failure = caller == outsider
            ? isA<NotAMemberException>()
            : isA<ServerpodUnauthenticatedException>();
        final calls = <Future<Object?>>[
          endpoints.match.inbox(caller, venue.id!),
          endpoints.match.forReport(caller, report.id!),
          endpoints.match.forItem(caller, item.id!),
          endpoints.match.rematch(caller, report.id!),
          endpoints.match.confirm(caller, match.id!),
          endpoints.match.reject(caller, match.id!, 'Different item'),
        ];
        await Future.wait(calls.map((f) => expectLater(f, throwsA(failure))));
      }
    });
    test(
      'inbox filters labels and states and removes owner secrets and vectors',
      () async {
        final others = await competitors();
        await ItemMatch.db.updateRow(s, others[0].copyWith(label: 'weak'));
        await ItemMatch.db.updateRow(
          s,
          others[1].copyWith(state: MatchState.rejected),
        );
        final cards = await endpoints.match.inbox(member, venue.id!);
        expect(cards, hasLength(1));
        expect(cards.single.match.id, match.id);
        expect(cards.single.item.embedding, isNull);
        expect(cards.single.report.embedding, isNull);
        expect(cards.single.report.ipHash, isNull);
        expect(cards.single.report.publicToken, isEmpty);
        expect(
          (await LostReport.db.findById(s, report.id!))!.publicToken,
          report.publicToken,
        );
      },
    );
    test(
      'clear leader uses the exact margin and is hidden after confirmation',
      () async {
        final other = (await competitors()).first;
        await ItemMatch.db.updateRow(s, other.copyWith(score: .76, rank: 2));
        var cards = await endpoints.match.forReport(member, report.id!);
        expect(cards.first.clearLeader, isTrue);
        await ItemMatch.db.updateRow(s, other.copyWith(score: .76001, rank: 2));
        cards = await endpoints.match.forReport(member, report.id!);
        expect(cards.first.clearLeader, isFalse);
        await LostReport.db.updateRow(
          s,
          report.copyWith(status: ReportStatus.possibleMatch),
        );
        await ItemMatch.db.updateRow(s, other.copyWith(score: .5, rank: 2));
        expect(
          (await endpoints.match.forReport(
            member,
            report.id!,
          )).every((c) => !c.clearLeader),
          isTrue,
        );
      },
    );
    test(
      'confirm commits both parents, supersedes both sides, audits and streams',
      () async {
        final others = await competitors();
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        try {
          final card = await endpoints.match.confirm(member, match.id!);
          expect(card.match.state, MatchState.confirmed);
          expect(card.match.decidedByAuthUserId, actorId);
          expect(card.match.decidedAt, isNotNull);
          expect(card.report.status, ReportStatus.possibleMatch);
          expect(card.item.status, ItemStatus.matched);
          for (final other in others) {
            expect(
              (await ItemMatch.db.findById(s, other.id!))!.state,
              MatchState.superseded,
            );
          }
          final audits = await AuditEvent.db.find(
            s,
            where: (t) => t.venueId.equals(venue.id!),
          );
          expect(audits.map((a) => a.entityType).toSet(), {'report', 'item'});
          expect(
            audits.every(
              (a) =>
                  a.action == 'match_confirmed' &&
                  a.payload!.data['itemRef'] == item.refCode &&
                  a.payload!.data['reportRef'] == report.refCode,
            ),
            isTrue,
          );
          await flushEventQueue();
          expect(events.map((e) => e.kind).toSet(), {
            'matchStatus',
            'reportStatus',
            'itemStatus',
          });
          expect(events.where((e) => e.kind == 'matchStatus'), hasLength(3));
          expect(
            (await endpoints.match.forItem(member, item.id!)).first.match.state,
            MatchState.confirmed,
          );
          await expectLater(
            endpoints.match.confirm(member, match.id!),
            throwsA(isA<MatchStateException>()),
          );
        } finally {
          await sub.cancel();
        }
      },
    );
    test(
      'audit failure rolls back every change as observed by a second session',
      () async {
        final others = await competitors();
        await s.db.unsafeSimpleExecute(
          "ALTER TABLE audit_event ADD CONSTRAINT reject_confirm CHECK (action <> 'match_confirmed')",
        );
        try {
          await expectLater(
            endpoints.match.confirm(member, match.id!),
            throwsA(isA<DatabaseQueryException>()),
          );
          final second = builder.build();
          expect(
            (await ItemMatch.db.findById(second, match.id!))!.state,
            MatchState.pending,
          );
          expect(
            (await FoundItem.db.findById(second, item.id!))!.status,
            ItemStatus.unclaimed,
          );
          expect(
            (await LostReport.db.findById(second, report.id!))!.status,
            ReportStatus.searching,
          );
          for (final other in others) {
            expect(
              (await ItemMatch.db.findById(second, other.id!))!.state,
              MatchState.pending,
            );
          }
          expect(
            await AuditEvent.db.count(
              second,
              where: (t) => t.venueId.equals(venue.id!),
            ),
            0,
          );
        } finally {
          await s.db.unsafeSimpleExecute(
            'ALTER TABLE audit_event DROP CONSTRAINT reject_confirm',
          );
        }
      },
    );
    test('competing concurrent confirmations reserve the item once', () async {
      final rival = (await competitors()).last;
      final results = await Future.wait(
        [match, rival].map((m) async {
          try {
            await endpoints.match.confirm(member, m.id!);
            return true;
          } on MatchStateException {
            return false;
          }
        }),
      );
      expect(results.where((r) => r), hasLength(1));
      final rows = await endpoints.match.forItem(member, item.id!);
      expect(
        rows.where((c) => c.match.state == MatchState.confirmed),
        hasLength(1),
      );
      expect(
        rows.where((c) => c.match.state == MatchState.superseded),
        hasLength(1),
      );
    });
    test(
      'undo requires a reason and restores parents and superseded proposals',
      () async {
        final others = await competitors();
        await endpoints.match.confirm(member, match.id!);
        await expectLater(
          endpoints.match.reject(member, match.id!, ' '),
          throwsArgumentError,
        );
        final card = await endpoints.match.reject(
          member,
          match.id!,
          'Owner says handle is plastic',
        );
        expect(card.match.state, MatchState.rejected);
        expect(card.item.status, ItemStatus.unclaimed);
        expect(card.report.status, ReportStatus.searching);
        for (final other in others) {
          final row = (await ItemMatch.db.findById(s, other.id!))!;
          expect(row.state, MatchState.pending);
          expect(row.decidedAt, isNull);
        }
        final audits = await AuditEvent.db.find(
          s,
          where: (t) =>
              t.action.equals('match_rejected') & t.venueId.equals(venue.id!),
        );
        expect(audits, hasLength(2));
        expect(
          audits.every(
            (a) => a.payload!.summary == 'Owner says handle is plastic',
          ),
          isTrue,
        );
      },
    );
    test('released matches cannot be undone', () async {
      await endpoints.match.confirm(member, match.id!);
      await FoundItem.db.updateRow(
        s,
        item.copyWith(status: ItemStatus.claimed),
      );
      await expectLater(
        endpoints.match.reject(member, match.id!, 'Late change'),
        throwsA(isA<MatchStateException>()),
      );
      expect(
        (await ItemMatch.db.findById(s, match.id!))!.state,
        MatchState.confirmed,
      );
    });
    test('close rejects pending proposals and records the reason', () async {
      await endpoints.report.closeReport(member, report.id!, 'Owner found it');
      expect(
        (await ItemMatch.db.findById(s, match.id!))!.state,
        MatchState.rejected,
      );
      final audit = await AuditEvent.db.findFirstRow(
        s,
        where: (t) => t.entityId.equals(match.id!),
      );
      expect(audit!.payload!.summary, 'Report closed');
      expect(await endpoints.match.inbox(member, venue.id!), isEmpty);
    });
    test(
      'rematch preserves a pending job and staff outcome follows the latest audit',
      () async {
        final first = await endpoints.match.rematch(member, report.id!);
        final second = await endpoints.match.rematch(member, report.id!);
        expect(second.id, first.id);
        expect(second.updatedAt, first.updatedAt);
        await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: venue.id!,
            entityType: 'report',
            entityId: report.id!,
            action: 'match_failed',
          ),
        );
        expect(
          (await endpoints.report.getReport(
            member,
            report.id!,
          )).lastMatchOutcome,
          'match_failed',
        );
        await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: venue.id!,
            entityType: 'report',
            entityId: report.id!,
            action: 'match_completed',
            at: DateTime.now().toUtc().add(const Duration(seconds: 1)),
          ),
        );
        expect(
          (await endpoints.report.getReport(
            member,
            report.id!,
          )).lastMatchOutcome,
          'ok',
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
