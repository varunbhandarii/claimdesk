@Tags(['integration'])
library;

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/handlers/nightly_handler.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Bounded housekeeping', (builder, _) {
    test(
      'Contact, photo, overdue and report recovery scans stay bounded',
      () async {
        final s = builder.build(), now = DateTime.now().toUtc();
        final venue = await makeVenue(s);
        await LostReport.db.insert(s, [
          for (var i = 0; i < 201; i++)
            LostReport(
              venueId: venue.id!,
              refCode: 'PUR$i',
              publicToken: 'pur-$i',
              rawText: 'A lost item',
              colourHints: [],
              status: ReportStatus.closed,
              closedAt: now.subtract(const Duration(days: 31)),
              contactEmail: 'demo@example.test',
            ),
        ]);
        await FoundItem.db.insert(s, [
          for (var i = 0; i < 51; i++)
            FoundItem(
              venueId: venue.id!,
              refCode: 'PHO$i',
              loggedByAuthUserId: actorId,
              status: ItemStatus.claimed,
              restricted: true,
              photoPath: 'missing-$i',
              thumbPath: 'missing-thumb-$i',
              updatedAt: now.subtract(const Duration(days: 31)),
            ),
        ]);
        await FoundItem.db.insert(s, [
          for (var i = 0; i < 201; i++)
            FoundItem(
              venueId: venue.id!,
              refCode: 'DUE$i',
              loggedByAuthUserId: actorId,
              status: ItemStatus.unclaimed,
              handoffDueAt: now.subtract(const Duration(days: 1)),
            ),
        ]);
        final attributes = ItemAttributes(
          category: 'umbrella',
          colours: ['black'],
          marks: [],
          description: 'A black umbrella',
          personalDataKinds: [],
          keywords: ['umbrella'],
          source: 'report',
        );
        await LostReport.db.insert(s, [
          for (var i = 0; i < 101; i++)
            LostReport(
              venueId: venue.id!,
              refCode: 'EMR$i',
              publicToken: 'emr-$i',
              rawText: 'A lost umbrella',
              colourHints: [],
              status: ReportStatus.searching,
              attributes: attributes,
            ),
        ]);
        final job = await WorkItem.db.insertRow(
          s,
          WorkItem(
            kind: 'nightly',
            runAt: now,
            payload: WorkPayload(data: {}),
            state: WorkState.running,
            attempts: 1,
            updatedAt: now,
          ),
        );
        final handler = NightlyHandler(clock: () => now);
        await handler.run(s, job);
        expect(handler.lastCounts['contactPurged'], 200);
        expect(handler.lastCounts['photosPurged'], 50);
        expect(handler.lastCounts['overdue'], 200);
        expect(handler.lastCounts['reembedReports'], 100);
      },
    );
    test('Recovery and expiry respect their batch bounds', () async {
      final s = builder.build(), now = DateTime.now().toUtc();
      final venue = await makeVenue(s);
      await FoundItem.db.insert(s, [
        for (var i = 0; i < 201; i++)
          FoundItem(
            venueId: venue.id!,
            refCode: 'EXP$i',
            loggedByAuthUserId: actorId,
            status: ItemStatus.unclaimed,
            holdUntil: now.subtract(const Duration(days: 1)),
          ),
      ]);
      await FoundItem.db.insert(s, [
        for (var i = 0; i < 101; i++)
          FoundItem(
            venueId: venue.id!,
            refCode: 'EMB$i',
            loggedByAuthUserId: actorId,
            status: ItemStatus.unclaimed,
            captionText: 'An umbrella',
          ),
      ]);
      await LostReport.db.insert(s, [
        for (var i = 0; i < 201; i++)
          LostReport(
            venueId: venue.id!,
            refCode: 'OLD$i',
            publicToken: 'old-$i',
            rawText: 'A lost umbrella',
            colourHints: [],
            status: ReportStatus.searching,
            createdAt: now.subtract(const Duration(days: 61)),
          ),
      ]);
      final job = await WorkItem.db.insertRow(
        s,
        WorkItem(
          kind: 'nightly',
          runAt: now,
          payload: WorkPayload(data: {}),
          state: WorkState.running,
          attempts: 1,
          updatedAt: now,
        ),
      );
      final handler = NightlyHandler(clock: () => now);
      await handler.run(s, job);
      expect(handler.lastCounts['expired'], 200);
      expect(handler.lastCounts['closed'], 200);
      expect(handler.lastCounts['reembedItems'], 100);
      expect(handler.lastCounts['rescore'], 0);
      expect(
        await FoundItem.db.count(
          s,
          where: (t) => t.status.equals(ItemStatus.expired),
        ),
        200,
      );
      expect(
        await LostReport.db.count(
          s,
          where: (t) => t.status.equals(ReportStatus.searching),
        ),
        1,
      );
    });
  });
  withServerpod('Concurrent housekeeping runs', (builder, _) {
    test(
      'Manual and daily runs share current-state guards without duplicate expiry audits',
      () async {
        final s = builder.build(),
            now = DateTime.now().toUtc(),
            venue = await makeVenue(builder.build());
        final item = await makeItem(s, venue.id!);
        await FoundItem.db.updateRow(
          s,
          item.copyWith(
            status: ItemStatus.unclaimed,
            holdUntil: now.subtract(const Duration(days: 1)),
          ),
        );
        final jobs = await WorkItem.db.insert(s, [
          for (var i = 0; i < 2; i++)
            WorkItem(
              kind: 'nightly',
              runAt: now,
              payload: WorkPayload(data: {}),
              state: WorkState.running,
              attempts: 1,
              updatedAt: now,
            ),
        ]);
        final handlers = [
          NightlyHandler(clock: () => now),
          NightlyHandler(clock: () => now),
        ];
        await Future.wait([
          for (var i = 0; i < 2; i++) handlers[i].run(builder.build(), jobs[i]),
        ]);
        expect(
          handlers.fold<int>(0, (sum, h) => sum + h.lastCounts['expired']!),
          1,
        );
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) =>
                t.entityId.equals(item.id!) & t.action.equals('expired'),
          ),
          1,
        );
        await AuditEvent.db.deleteWhere(
          s,
          where: (t) => t.venueId.equals(venue.id!),
        );
        await Venue.db.deleteRow(s, venue);
        await WorkItem.db.deleteWhere(
          s,
          where: (t) => t.kind.equals('nightly'),
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
