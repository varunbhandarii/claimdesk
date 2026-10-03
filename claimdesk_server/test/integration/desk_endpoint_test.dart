import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Desk attention and previews', (builder, endpoints) {
    late Session session;
    late Venue venue;
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final stranger = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    setUp(() async {
      session = builder.build();
      venue = await makeVenue(session);
      await StaffMembership.db.insertRow(
        session,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Desk staff',
        ),
      );
    });
    Future<FoundItem> add(
      String ref,
      ItemStatus status, {
      DateTime? due,
      DateTime? hold,
    }) async {
      final item = await makeItem(
        session,
        venue.id!,
        refCode: ref,
        embedding: unitVector(1, 0),
      );
      return FoundItem.db.updateRow(
        session,
        item.copyWith(status: status, handoffDueAt: due, holdUntil: hold),
      );
    }

    test(
      'uncapped counts, capped previews and filters share the same conditions',
      () async {
        final now = DateTime.now().toUtc();
        final failed = await add('FAIL01', ItemStatus.captioning);
        await WorkItem.db.insertRow(
          session,
          WorkItem(
            venueId: venue.id!,
            kind: 'caption_item',
            payload: WorkPayload(entityId: failed.id, data: {}),
            identifier: 'caption_${failed.id}',
            runAt: now,
            state: WorkState.failed,
          ),
        );
        await add('WAIT01', ItemStatus.captioning);
        final overdue = <FoundItem>[];
        for (var n = 0; n < 6; n++) {
          overdue.add(
            await add(
              'DUE00$n',
              ItemStatus.unclaimed,
              due: now.subtract(Duration(days: n + 1)),
            ),
          );
        }
        final expired = await add(
          'EXPIRE',
          ItemStatus.expired,
          hold: now.subtract(const Duration(days: 2)),
        );
        final soon = await add(
          'SOON01',
          ItemStatus.unclaimed,
          hold: now.add(const Duration(days: 2)),
        );
        await add(
          'FUTURE',
          ItemStatus.unclaimed,
          due: now.add(const Duration(days: 4)),
          hold: now.add(const Duration(days: 4)),
        );
        await add(
          'DONE01',
          ItemStatus.claimed,
          due: now.subtract(const Duration(days: 5)),
          hold: now.add(const Duration(days: 1)),
        );
        await add(
          'GONE01',
          ItemStatus.transferred,
          due: now.subtract(const Duration(days: 5)),
        );
        await add(
          'GONE02',
          ItemStatus.disposed,
          due: now.subtract(const Duration(days: 5)),
        );
        final report = await makeReport(session, venue.id!);
        await makeMatch(session, overdue[0], report);
        final possible = await makeMatch(session, overdue[1], report);
        await ItemMatch.db.updateRow(
          session,
          possible.copyWith(label: 'possible'),
        );
        final weak = await makeMatch(session, overdue[2], report);
        await ItemMatch.db.updateRow(session, weak.copyWith(label: 'weak'));
        final decided = await makeMatch(session, overdue[3], report);
        await ItemMatch.db.updateRow(
          session,
          decided.copyWith(state: MatchState.confirmed),
        );
        final other = await makeVenue(session, slug: 'other-desk');
        await makeItem(session, other.id!, refCode: 'OTHER1');
        final summary = await endpoints.desk.summary(member, venue.id!);
        expect(summary.newMatches, 2);
        expect(summary.openReports, 1);
        expect(summary.captioningFailedCount, 1);
        expect(summary.captioningFailed.single.id, failed.id);
        expect(summary.overdueCount, 6);
        expect(summary.overdue, hasLength(5));
        expect(summary.overdue.first.id, overdue.last.id);
        expect(summary.expiringSoonCount, 1);
        expect(summary.expiringSoon.single.id, soon.id);
        expect(summary.expiredCount, 1);
        expect(summary.expired.single.id, expired.id);
        expect(summary.onShelf, 8);
        expect(summary.returnedThisWeek, 1);
        expect(summary.recent, hasLength(5));
        for (final rows in [
          summary.captioningFailed,
          summary.overdue,
          summary.expiringSoon,
          summary.expired,
          summary.recent,
        ]) {
          expect(
            rows.every((i) => i.venueId == venue.id && i.embedding == null),
            true,
          );
        }
        for (final (key, expected) in [
          ('captioningFailed', [failed]),
          ('overdue', overdue),
          ('expiringSoon', [soon]),
        ]) {
          final rows = await endpoints.item.listItems(
            member,
            venue.id!,
            ItemFilter(attention: key),
          );
          expect(
            rows.map((r) => r.id),
            unorderedEquals(expected.map((r) => r.id)),
          );
          expect(rows.every((r) => r.embedding == null), true);
        }
      },
    );
    test(
      'overdue presets include expired items but exclude terminal states and foreign jobs',
      () async {
        final now = DateTime.now().toUtc();
        final expired = await add(
          'EXPIRE',
          ItemStatus.expired,
          due: now.subtract(const Duration(days: 1)),
        );
        final pending = await add('WAIT01', ItemStatus.captioning);
        final other = await makeVenue(session, slug: 'other-desk');
        await WorkItem.db.insertRow(
          session,
          WorkItem(
            venueId: other.id!,
            kind: 'caption_item',
            payload: WorkPayload(entityId: pending.id, data: {}),
            identifier: 'caption_${pending.id}',
            runAt: now,
            state: WorkState.failed,
          ),
        );
        final summary = await endpoints.desk.summary(member, venue.id!);
        expect(summary.overdue.single.id, expired.id);
        expect(summary.captioningFailedCount, 0);
        expect(
          (await endpoints.item.listItems(
            member,
            venue.id!,
            ItemFilter(attention: 'overdue'),
          )).single.id,
          expired.id,
        );
      },
    );
    test('non-members cannot read counts or attention views', () async {
      await expectLater(
        endpoints.desk.summary(stranger, venue.id!),
        throwsA(isA<NotAMemberException>()),
      );
      await expectLater(
        endpoints.item.listItems(
          stranger,
          venue.id!,
          ItemFilter(attention: 'overdue'),
        ),
        throwsA(isA<NotAMemberException>()),
      );
    });
  });
}
