import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../matching/candidate_query.dart';
import '../../matching/scorer.dart';
import '../../policy/retention.dart';
import '../job_handler.dart';
import '../job_queue.dart';
import '../job_wakeup.dart';
import '../nightly.dart';

class NightlyHandler extends JobHandler {
  NightlyHandler({DateTime Function()? clock})
    : clock = clock ?? (() => DateTime.now().toUtc());
  final DateTime Function() clock;
  Map<String, int> lastCounts = {};
  @override
  String get kind => 'nightly';
  @override
  Future<void> run(Session session, WorkItem job) async {
    if (job.venueId != null || !await JobClaim.current(session, job)) return;
    final now = clock().toUtc();
    await Nightly.schedule(session, now: now, tomorrow: true);
    final counts = <String, int>{
      'reembedItems': 0,
      'reembedReports': 0,
      'rescore': 0,
      'expired': 0,
      'closed': 0,
      'contactPurged': 0,
      'photosPurged': 0,
      'overdue': 0,
    };
    final events = <DeskEvent>[];
    Future<void> step(Future<void> Function(Transaction) write) async {
      await session.db.transaction((tx) async {
        if (await JobClaim.current(session, job, transaction: tx, lock: true)) {
          await write(tx);
        }
      });
    }

    Future<bool> enqueue(
      Transaction tx,
      UuidValue venue,
      UuidValue entity,
      String kind,
    ) async {
      final identifier = '${kind}_$entity';
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@identifier, 0))',
        parameters: QueryParameters.named({'identifier': identifier}),
        transaction: tx,
      );
      final old = await WorkItem.db.findFirstRow(
        session,
        where: (t) => t.identifier.equals(identifier),
        transaction: tx,
      );
      if (old != null &&
          {WorkState.pending, WorkState.running}.contains(old.state)) {
        return false;
      }
      await JobQueue.enqueue(
        session,
        kind: kind,
        venueId: venue,
        identifier: identifier,
        payload: WorkPayload(entityId: entity, data: {}),
        maxAttempts: kind == 'match_report' ? 4 : 5,
        transaction: tx,
      );
      return true;
    }

    Future<void> audit(
      Transaction tx,
      UuidValue venue,
      String type,
      UuidValue id,
      String action,
      String summary, {
      Map<String, String> data = const {},
    }) => AuditEvent.db
        .insertRow(
          session,
          AuditEvent(
            venueId: venue,
            entityType: type,
            entityId: id,
            action: action,
            at: now,
            payload: AuditPayload(summary: summary, data: data),
          ),
          transaction: tx,
        )
        .then((_) {});
    void event(
      UuidValue venue,
      String kind, {
      UuidValue? item,
      UuidValue? report,
    }) => events.add(
      DeskEvent(
        kind: kind,
        venueId: venue,
        itemId: item,
        reportId: report,
        at: now,
      ),
    );
    await step((tx) async {
      final missingItemIds = (await session.db.unsafeQuery(
        'SELECT id FROM found_item WHERE embedding IS NULL AND "captionText" IS NOT NULL AND status IN (\'unclaimed\',\'matched\') ORDER BY id LIMIT 100',
        transaction: tx,
      )).map((r) => UuidValue.fromString(r[0].toString())).toSet();
      final missingReportIds = (await session.db.unsafeQuery(
        'SELECT id FROM lost_report WHERE embedding IS NULL AND attributes IS NOT NULL AND status IN (\'received\',\'searching\',\'possibleMatch\') ORDER BY id LIMIT 100',
        transaction: tx,
      )).map((r) => UuidValue.fromString(r[0].toString())).toSet();
      final items = await FoundItem.db.find(
        session,
        where: (t) =>
            t.status.inSet({ItemStatus.unclaimed, ItemStatus.matched}) &
            t.id.inSet(missingItemIds) &
            t.captionText.notEquals(null),
        orderBy: (t) => t.id,
        limit: 100,
        transaction: tx,
      );
      for (final item in items) {
        if (await enqueue(tx, item.venueId, item.id!, 'reembed_item')) {
          counts['reembedItems'] = counts['reembedItems']! + 1;
        }
      }
      final reports = await LostReport.db.find(
        session,
        where: (t) =>
            t.status.inSet(CandidateQuery.openReports) &
            t.id.inSet(missingReportIds),
        orderBy: (t) => t.id,
        limit: 100,
        transaction: tx,
      );
      for (final report in reports) {
        if (await enqueue(tx, report.venueId, report.id!, 'match_report')) {
          counts['reembedReports'] = counts['reembedReports']! + 1;
        }
      }
    });
    await step((tx) async {
      final rows = await session.db.unsafeQuery(
        '''SELECT DISTINCT r.id, r."venueId" FROM lost_report r
        WHERE r.status IN ('received', 'searching', 'possibleMatch') AND
        ((r.status = 'received' AND r."createdAt" < @cutoff) OR EXISTS
         (SELECT 1 FROM item_match m WHERE m."reportId"=r.id AND m.state='pending'
          AND (m."algorithmVersion" <> @version OR m.explanation->>'weightsHash' IS DISTINCT FROM @hash)))
        ORDER BY r.id LIMIT 200''',
        parameters: QueryParameters.named({
          'cutoff': now.subtract(const Duration(minutes: 10)),
          'version': Scorer.algorithmVersion,
          'hash': const Scorer().weights.hash,
        }),
        transaction: tx,
      );
      for (final row in rows) {
        if (await enqueue(
          tx,
          UuidValue.fromString(row[1].toString()),
          UuidValue.fromString(row[0].toString()),
          'match_report',
        )) {
          counts['rescore'] = counts['rescore']! + 1;
        }
      }
    });
    await step((tx) async {
      final items = await FoundItem.db.find(
        session,
        where: (t) =>
            t.status.equals(ItemStatus.unclaimed) & (t.holdUntil < now),
        orderBy: (t) => t.id,
        limit: 200,
        transaction: tx,
        lockMode: LockMode.forUpdate,
        lockBehavior: LockBehavior.skipLocked,
      );
      for (final item in items) {
        final venue = await Venue.db.findById(
          session,
          item.venueId,
          transaction: tx,
        );
        if (venue == null) continue;
        await FoundItem.db.updateRow(
          session,
          item.copyWith(status: ItemStatus.expired, updatedAt: now),
          transaction: tx,
        );
        await ItemMatch.db.updateWhere(
          session,
          columnValues: (t) => [
            t.state(MatchState.rejected),

            t.updatedAt(now),
          ],
          where: (t) =>
              t.itemId.equals(item.id!) & t.state.equals(MatchState.pending),
          transaction: tx,
        );
        await audit(
          tx,
          item.venueId,
          'item',
          item.id!,
          'expired',
          'Item hold period ended',
          data: {
            'recommendedAction': recommendedDisposal(
              venue,
              item.attributes?.category ?? 'other',
            ),
          },
        );
        counts['expired'] = counts['expired']! + 1;
        event(item.venueId, 'itemStatus', item: item.id);
      }
    });
    await step((tx) async {
      final reports = await LostReport.db.find(
        session,
        where: (t) =>
            t.status.inSet({ReportStatus.received, ReportStatus.searching}) &
            (t.createdAt < now.subtract(reportOpenRetention)),
        orderBy: (t) => t.id,
        limit: 200,
        transaction: tx,
        lockMode: LockMode.forUpdate,
        lockBehavior: LockBehavior.skipLocked,
      );
      for (final report in reports) {
        await LostReport.db.updateRow(
          session,
          report.copyWith(
            status: ReportStatus.closed,
            closedAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
        await ItemMatch.db.updateWhere(
          session,
          columnValues: (t) => [
            t.state(MatchState.rejected),

            t.updatedAt(now),
          ],
          where: (t) =>
              t.reportId.equals(report.id!) &
              t.state.equals(MatchState.pending),
          transaction: tx,
        );
        await audit(
          tx,
          report.venueId,
          'report',
          report.id!,
          'closed',
          'Closed by retention after 60 days',
        );
        counts['closed'] = counts['closed']! + 1;
        event(report.venueId, 'reportStatus', report: report.id);
      }
    });
    await step((tx) async {
      final reports = await LostReport.db.find(
        session,
        where: (t) =>
            t.status.inSet({ReportStatus.closed, ReportStatus.returned}) &
            (t.closedAt < now.subtract(contactRetention)) &
            t.contactPurgedAt.equals(null),
        orderBy: (t) => t.id,
        limit: 200,
        transaction: tx,
        lockMode: LockMode.forUpdate,
        lockBehavior: LockBehavior.skipLocked,
      );
      for (final report in reports) {
        await LostReport.db.updateRow(
          session,
          report.copyWith(
            contactEmail: null,
            ownerName: null,
            ownerOnlyDetails: null,
            contactPurgedAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
        await ReportAnswer.db.deleteWhere(
          session,
          where: (t) => t.reportId.equals(report.id!),
          transaction: tx,
        );
        await audit(
          tx,
          report.venueId,
          'report',
          report.id!,
          'contact_purged',
          'Expired contact and verification details removed',
        );
        counts['contactPurged'] = counts['contactPurged']! + 1;
      }
    });
    await step((tx) async {
      final items = await FoundItem.db.find(
        session,
        where: (t) =>
            t.restricted.equals(true) &
            t.status.inSet({
              ItemStatus.claimed,
              ItemStatus.transferred,
              ItemStatus.disposed,
              ItemStatus.expired,
            }) &
            (t.updatedAt < now.subtract(restrictedPhotoRetention)) &
            t.photoPath.notEquals(null),
        orderBy: (t) => t.id,
        limit: 50,
        transaction: tx,
        lockMode: LockMode.forUpdate,
        lockBehavior: LockBehavior.skipLocked,
      );
      for (final item in items) {
        for (final path in {
          item.photoPath,
          item.thumbPath,
        }.whereType<String>()) {
          if (await session.storage.fileExists(
            storageId: 'private',
            path: path,
          )) {
            await session.storage.deleteFile(storageId: 'private', path: path);
          }
        }
        await FoundItem.db.updateRow(
          session,
          item.copyWith(photoPath: null, thumbPath: null),
          transaction: tx,
        );
        await audit(
          tx,
          item.venueId,
          'item',
          item.id!,
          'photo_purged',
          'Expired restricted photos removed',
        );
        counts['photosPurged'] = counts['photosPurged']! + 1;
      }
    });
    await step((tx) async {
      final ids = await session.db.unsafeQuery(
        '''SELECT i.id FROM found_item i WHERE i.status IN ('unclaimed','matched')
        AND i."handoffDueAt" < @now AND NOT EXISTS (SELECT 1 FROM audit_event a WHERE a."entityId"=i.id AND a."entityType"='item' AND a.action='handoff_overdue') ORDER BY i.id LIMIT 200''',
        parameters: QueryParameters.named({'now': now}),
        transaction: tx,
      );
      for (final row in ids) {
        final item = await FoundItem.db.findById(
          session,
          UuidValue.fromString(row[0].toString()),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (item == null ||
            !{ItemStatus.unclaimed, ItemStatus.matched}.contains(item.status)) {
          continue;
        }
        if (await AuditEvent.db.findFirstRow(
              session,
              where: (t) =>
                  t.entityId.equals(item.id!) &
                  t.entityType.equals('item') &
                  t.action.equals('handoff_overdue'),
              transaction: tx,
            ) !=
            null) {
          continue;
        }
        await audit(
          tx,
          item.venueId,
          'item',
          item.id!,
          'handoff_overdue',
          'Item handoff is overdue',
        );
        counts['overdue'] = counts['overdue']! + 1;
        event(item.venueId, 'itemStatus', item: item.id);
      }
    });
    JobWakeup.notify(session);
    for (final message in events) {
      await session.messages.postMessage('venue_${message.venueId}', message);
    }
    lastCounts = counts;
    session.log(
      'Nightly summary: ${counts.entries.map((e) => '${e.key}=${e.value}').join(' ')}',
    );
  }
}
