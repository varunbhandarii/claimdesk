import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the desk schema', (builder, _) {
    late Session s;
    late Venue venue;
    late FoundItem item;
    late LostReport report;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      item = await makeItem(s, venue.id!);
      report = await makeReport(s, venue.id!);
    });

    test(
      'when a membership is duplicated then its natural key is rejected',
      () async {
        final row = StaffMembership(
          authUserId: actorId,
          venueId: venue.id!,
          displayName: 'Staff',
        );
        await StaffMembership.db.insertRow(s, row);
        await expectLater(
          StaffMembership.db.insertRow(s, row),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when the same item and report are matched twice then the duplicate is rejected',
      () async {
        await makeMatch(s, item, report);
        await expectLater(
          makeMatch(s, item, report),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when item reference repeats within a venue then it is rejected',
      () async {
        await expectLater(
          makeItem(s, venue.id!),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when report reference repeats within a venue then it is rejected',
      () async {
        await expectLater(
          makeReport(s, venue.id!, publicToken: 'another-token'),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when references repeat in different venues then they are allowed',
      () async {
        final other = await makeVenue(s, slug: 'other');
        await makeItem(s, other.id!);
        await makeReport(s, other.id!, publicToken: 'another-token');
        expect(await FoundItem.db.count(s), 2);
        expect(await LostReport.db.count(s), 2);
      },
    );

    test(
      'when public token repeats across venues then it is rejected',
      () async {
        final other = await makeVenue(s, slug: 'other');
        await expectLater(
          makeReport(s, other.id!),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test('when venue slug repeats then it is rejected', () async {
      await expectLater(
        makeVenue(s),
        throwsA(isA<DatabaseUniqueViolationException>()),
      );
    });

    test('when zone name repeats within a venue then it is rejected', () async {
      final zone = Zone(venueId: venue.id!, name: 'Desk', adjacentZoneIds: []);
      await Zone.db.insertRow(s, zone);
      await expectLater(
        Zone.db.insertRow(s, zone),
        throwsA(isA<DatabaseUniqueViolationException>()),
      );
    });

    Future<ReleaseRecord> release({UuidValue? reportId}) =>
        ChildRecords.release(
          s,
          itemId: item.id!,
          reportId: reportId,
          claimantName: 'Fictional Owner',
          idTypeSeen: 'Photo ID',
          detailsMatched: 2,
          describedBeforeViewing: true,
          releasedByAuthUserId: actorId,
        );

    test(
      'when a release row is duplicated then the database rejects it',
      () async {
        final row = await release();
        await expectLater(
          ReleaseRecord.db.insertRow(s, row.copyWith(id: null)),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when the release path is repeated then it maps to a typed product error',
      () async {
        await release();
        await expectLater(
          release(),
          throwsA(
            isA<AlreadyReleasedException>().having(
              (e) => e.itemId,
              'itemId',
              item.id,
            ),
          ),
        );
      },
    );

    test(
      'when an item has a release record then deleting it is refused',
      () async {
        await release();
        await expectLater(
          FoundItem.db.deleteRow(s, item),
          throwsA(isA<DatabaseForeignKeyViolationException>()),
        );
      },
    );

    test(
      'when a linked report is deleted then the permanent release survives',
      () async {
        final row = await release(reportId: report.id);
        await LostReport.db.deleteRow(s, report);
        final stored = await ReleaseRecord.db.findById(s, row.id!);
        expect(stored!.reportId, isNull);
        expect(stored.itemId, item.id);
      },
    );

    test(
      'when a zone is deleted then item and report zone references become null',
      () async {
        final zone = await Zone.db.insertRow(
          s,
          Zone(venueId: venue.id!, name: 'Desk', adjacentZoneIds: []),
        );
        await FoundItem.db.updateRow(s, item.copyWith(zoneId: zone.id));
        await LostReport.db.updateRow(s, report.copyWith(zoneId: zone.id));
        await Zone.db.deleteRow(s, zone);
        expect((await FoundItem.db.findById(s, item.id!))!.zoneId, isNull);
        expect((await LostReport.db.findById(s, report.id!))!.zoneId, isNull);
      },
    );

    test(
      'when children are created through their service paths then tenant ids come from their parents',
      () async {
        final match = await makeMatch(s, item, report);
        final caption = await ChildRecords.caption(
          s,
          itemId: item.id!,
          provider: 'test',
          modelId: 'fixture',
          promptVersion: '1',
          outcome: 'ok',
          latencyMs: 1,
        );
        final answer = await ChildRecords.answer(
          s,
          matchId: match.id!,
          question: 'Mark?',
          answer: 'Chip',
        );
        final custody = await ChildRecords.custody(
          s,
          itemId: item.id!,
          fromLocation: 'Desk',
          toLocation: 'Shelf',
          byAuthUserId: actorId,
        );
        final released = await release(reportId: report.id);
        expect(
          (await CaptionRun.db.findById(s, caption.id!))!.venueId,
          item.venueId,
        );
        expect(
          (await ReportAnswer.db.findById(s, answer.id!))!.venueId,
          report.venueId,
        );
        expect(
          (await CustodyEvent.db.findById(s, custody.id!))!.venueId,
          item.venueId,
        );
        expect(
          (await ReleaseRecord.db.findById(s, released.id!))!.venueId,
          item.venueId,
        );
      },
    );

    test(
      'when a release references another venue then its creation is refused',
      () async {
        final other = await makeVenue(s, slug: 'other');
        final unrelated = await makeReport(
          s,
          other.id!,
          publicToken: 'other-token',
        );
        await expectLater(release(reportId: unrelated.id), throwsArgumentError);
        expect(await ReleaseRecord.db.count(s), 0);
      },
    );

    test(
      'when match parents have different venues then answers are refused',
      () async {
        final other = await makeVenue(s, slug: 'other');
        final unrelated = await makeReport(
          s,
          other.id!,
          publicToken: 'other-token',
        );
        final invalid = await makeMatch(s, item, unrelated);
        await expectLater(
          ChildRecords.answer(
            s,
            matchId: invalid.id!,
            question: 'Mark?',
            answer: 'Chip',
          ),
          throwsArgumentError,
        );
        expect(await ReportAnswer.db.count(s), 0);
      },
    );

    test(
      'when a venue is deleted then all venue rows cascade while audit and global work survive',
      () async {
        final match = await makeMatch(s, item, report);
        await Zone.db.insertRow(
          s,
          Zone(venueId: venue.id!, name: 'Desk', adjacentZoneIds: []),
        );
        await StaffMembership.db.insertRow(
          s,
          StaffMembership(
            authUserId: actorId,
            venueId: venue.id!,
            displayName: 'Staff',
          ),
        );
        await ChildRecords.caption(
          s,
          itemId: item.id!,
          provider: 'test',
          modelId: 'fixture',
          promptVersion: '1',
          outcome: 'ok',
          latencyMs: 1,
        );
        await ChildRecords.answer(
          s,
          matchId: match.id!,
          question: 'Mark?',
          answer: 'Chip',
        );
        await ChildRecords.custody(
          s,
          itemId: item.id!,
          fromLocation: 'Desk',
          toLocation: 'Shelf',
          byAuthUserId: actorId,
        );
        await release(reportId: report.id);
        final audit = await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: venue.id!,
            entityType: 'item',
            entityId: item.id!,
            action: 'created',
          ),
        );
        await WorkItem.db.insertRow(
          s,
          WorkItem(
            venueId: venue.id!,
            kind: 'caption',
            payload: WorkPayload(entityId: item.id, data: {}),
            runAt: DateTime.now().toUtc(),
          ),
        );
        final global = await WorkItem.db.insertRow(
          s,
          WorkItem(
            kind: 'nightly',
            payload: WorkPayload(data: {}),
            runAt: DateTime.now().toUtc(),
          ),
        );
        await Venue.db.deleteRow(s, venue);
        expect(await Zone.db.count(s), 0);
        expect(await StaffMembership.db.count(s), 0);
        expect(await FoundItem.db.count(s), 0);
        expect(await LostReport.db.count(s), 0);
        expect(await ItemMatch.db.count(s), 0);
        expect(await CaptionRun.db.count(s), 0);
        expect(await ReportAnswer.db.count(s), 0);
        expect(await CustodyEvent.db.count(s), 0);
        expect(await ReleaseRecord.db.count(s), 0);
        expect((await WorkItem.db.find(s)).single.id, global.id);
        expect((await AuditEvent.db.find(s)).single.id, audit.id);
      },
    );

    test(
      'when a row is inserted without an id then Postgres supplies UUID v7',
      () async {
        expect(venue.id!.uuid[14], '7');
        expect(item.id!.uuid[14], '7');
        expect(report.id!.uuid[14], '7');
        expect(item.createdAt.isUtc, isTrue);
      },
    );
  });
}
