@Tags(['integration'])
library;

import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/handlers/nightly_handler.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Idempotent desk housekeeping', (builder, _) {
    test(
      'closing an old searching report releases its reservation but preserves active pickup',
      () async {
        final s = builder.build(), now = DateTime.now().toUtc();
        final venue = await makeVenue(s);
        var oldReport = await makeReport(s, venue.id!, refCode: 'OLDRES');
        oldReport = await LostReport.db.updateRow(
          s,
          oldReport.copyWith(
            status: ReportStatus.searching,
            createdAt: now.subtract(const Duration(days: 61)),
          ),
        );
        var item = await makeItem(s, venue.id!, refCode: 'RESERV');
        item = await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.matched),
        );
        final match = await makeMatch(s, item, oldReport);
        await ItemMatch.db.updateRow(
          s,
          match.copyWith(state: MatchState.confirmed),
        );
        var active = await makeReport(
          s,
          venue.id!,
          refCode: 'PICKUP',
          publicToken: 'active-pickup',
        );
        active = await LostReport.db.updateRow(
          s,
          active.copyWith(
            status: ReportStatus.readyForPickup,
            createdAt: now.subtract(const Duration(days: 61)),
          ),
        );
        final job = await WorkItem.db.insertRow(
          s,
          WorkItem(
            runAt: now,
            kind: 'nightly',
            payload: WorkPayload(data: {}),
            state: WorkState.running,
            attempts: 1,
            updatedAt: now,
            leaseUntil: now.add(const Duration(minutes: 2)),
          ),
        );
        final handler = NightlyHandler(clock: () => now);
        await handler.run(s, job);
        expect(
          (await LostReport.db.findById(s, oldReport.id!))!.status,
          ReportStatus.closed,
        );
        expect(
          (await FoundItem.db.findById(s, item.id!))!.status,
          ItemStatus.unclaimed,
        );
        expect(
          (await ItemMatch.db.findById(s, match.id!))!.state,
          MatchState.rejected,
        );
        expect(
          (await LostReport.db.findById(s, active.id!))!.status,
          ReportStatus.readyForPickup,
        );
        await handler.run(s, job);
        expect(handler.lastCounts['closed'], 0);
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) =>
                t.entityId.equals(item.id!) &
                t.action.equals('reservation_closed'),
          ),
          1,
        );
      },
    );
    test(
      'Each retention step runs once, recovery work is preserved and release proof survives',
      () async {
        final s = builder.build(), now = DateTime.now().toUtc();
        final venue = await makeVenue(s);
        var expired = await makeItem(s, venue.id!, refCode: 'EXPIRE');
        expired = await FoundItem.db.updateRow(
          s,
          expired.copyWith(
            status: ItemStatus.unclaimed,
            holdUntil: now.subtract(const Duration(seconds: 1)),
          ),
        );
        var overdue = await makeItem(s, venue.id!, refCode: 'OVERDU');
        overdue = await FoundItem.db.updateRow(
          s,
          overdue.copyWith(
            status: ItemStatus.matched,
            handoffDueAt: now.subtract(const Duration(days: 1)),
          ),
        );
        var reembed = await makeItem(s, venue.id!, refCode: 'EMBED1');
        reembed = await FoundItem.db.updateRow(
          s,
          reembed.copyWith(
            status: ItemStatus.unclaimed,
            captionText: 'Plain umbrella',
          ),
        );
        var stale = await makeReport(
          s,
          venue.id!,
          refCode: 'STALE1',
          publicToken: 'stale',
        );
        stale = await LostReport.db.updateRow(
          s,
          stale.copyWith(
            status: ReportStatus.searching,
            createdAt: now.subtract(const Duration(days: 61)),
            embedding: unitVector(1, 0),
          ),
        );
        final pending = await makeMatch(s, expired, stale);
        var closed = await makeReport(
          s,
          venue.id!,
          refCode: 'CLOSE1',
          publicToken: 'closed',
        );
        closed = await LostReport.db.updateRow(
          s,
          closed.copyWith(
            status: ReportStatus.returned,
            closedAt: now.subtract(const Duration(days: 31)),
            contactEmail: 'private@example.test',
            ownerName: 'Private Owner',
            ownerOnlyDetails: 'Private proof',
          ),
        );
        var restricted = await makeItem(s, venue.id!, refCode: 'PHOTO1');
        final photo = 'tests/${const Uuid().v4()}.jpg',
            thumb = 'tests/${const Uuid().v4()}.thumb.jpg',
            sig = 'tests/${const Uuid().v4()}.png';
        restricted = await FoundItem.db.updateRow(
          s,
          restricted.copyWith(
            status: ItemStatus.claimed,
            restricted: true,
            photoPath: photo,
            thumbPath: thumb,
            updatedAt: now.subtract(const Duration(days: 31)),
          ),
        );
        for (final path in [photo, thumb, sig]) {
          await s.storage.storeFile(
            storageId: 'private',
            path: path,
            byteData: ByteData(8),
          );
        }
        final confirmed = await makeMatch(s, restricted, closed);
        await ItemMatch.db.updateRow(
          s,
          confirmed.copyWith(state: MatchState.confirmed),
        );
        await ChildRecords.answer(
          s,
          matchId: confirmed.id!,
          question: 'Private question',
          answer: 'Private answer',
        );
        final release = await ChildRecords.release(
          s,
          itemId: restricted.id!,
          reportId: closed.id,
          claimantName: 'Permanent release name',
          idTypeSeen: 'passport',
          detailsMatched: 2,
          describedBeforeViewing: true,
          releasedByAuthUserId: actorId,
          signaturePath: sig,
        );
        final control = await makeItem(s, venue.id!, refCode: 'SAFE01');
        final job = await WorkItem.db.insertRow(
          s,
          WorkItem(
            runAt: now,
            kind: 'nightly',
            payload: WorkPayload(data: {}),
            state: WorkState.running,
            attempts: 1,
            updatedAt: now,
            leaseUntil: now.add(const Duration(minutes: 2)),
          ),
        );
        final handler = NightlyHandler(clock: () => now);
        try {
          await handler.run(s, job);
          expect(handler.lastCounts['expired'], 1);
          expect(handler.lastCounts['closed'], 1);
          expect(handler.lastCounts['contactPurged'], 1);
          expect(handler.lastCounts['photosPurged'], 1);
          expect(handler.lastCounts['overdue'], 1);
          expect(handler.lastCounts['reembedItems'], 1);
          expect(
            (await FoundItem.db.findById(s, expired.id!))!.status,
            ItemStatus.expired,
          );
          expect(
            (await LostReport.db.findById(s, stale.id!))!.status,
            ReportStatus.closed,
          );
          final purged = (await LostReport.db.findById(s, closed.id!))!;
          expect(purged.contactEmail, isNull);
          expect(purged.ownerName, isNull);
          expect(purged.ownerOnlyDetails, isNull);
          expect(purged.contactPurgedAt, now);
          expect(
            await ReportAnswer.db.count(
              s,
              where: (t) => t.reportId.equals(closed.id!),
            ),
            0,
          );
          expect(
            (await ItemMatch.db.findById(s, pending.id!))!.state,
            MatchState.rejected,
          );
          expect(
            (await FoundItem.db.findById(s, restricted.id!))!.photoPath,
            isNull,
          );
          expect(
            await s.storage.fileExists(storageId: 'private', path: photo),
            isFalse,
          );
          expect(
            await s.storage.fileExists(storageId: 'private', path: thumb),
            isFalse,
          );
          expect(
            await s.storage.fileExists(storageId: 'private', path: sig),
            isTrue,
          );
          expect(
            (await ReleaseRecord.db.findById(s, release.id!))!.claimantName,
            'Permanent release name',
          );
          expect(
            (await FoundItem.db.findById(s, control.id!))!.status,
            control.status,
          );
          final audits = await AuditEvent.db.count(
            s,
            where: (t) => t.venueId.equals(venue.id!),
          );
          await handler.run(s, job);
          expect(
            handler.lastCounts.values.every((count) => count == 0),
            isTrue,
          );
          expect(
            await AuditEvent.db.count(
              s,
              where: (t) => t.venueId.equals(venue.id!),
            ),
            audits,
          );
          expect(
            await WorkItem.db.count(
              s,
              where: (t) => t.identifier.equals(
                'nightly_${DateTime.utc(now.year, now.month, now.day).add(const Duration(days: 1)).toIso8601String().split('T').first}',
              ),
            ),
            1,
          );
          final staleClaim = job.copyWith(attempts: 2);
          handler.lastCounts = {};
          await handler.run(s, staleClaim);
          expect(handler.lastCounts, isEmpty);
        } finally {
          for (final path in [photo, thumb, sig]) {
            if (await s.storage.fileExists(storageId: 'private', path: path)) {
              await s.storage.deleteFile(storageId: 'private', path: path);
            }
          }
        }
      },
    );
  });
}
