import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../access/venue_guard.dart';
import '../db/transactions.dart';
import '../generated/protocol.dart';
import '../policy/release_rules.dart';
import '../services/child_records.dart';
import '../services/staff_views.dart';

class ReleaseEndpoint extends Endpoint with VenueGuard {
  @override
  bool get logSessions => false;
  Future<FoundItem> _item(Session session, UuidValue id) async {
    final item = await FoundItem.db.findById(session, id);
    if (item == null) {
      throw ReleaseRefusedException(message: 'Item not found', itemId: id);
    }
    await requireMembership(session, item.venueId);
    return item;
  }

  Future<MatchCard> markReady(Session session, UuidValue matchId) async {
    final authorized = await ItemMatch.db.findById(session, matchId);
    if (authorized == null) {
      throw MatchStateException(message: 'Match not found', matchId: matchId);
    }
    await requireMembership(session, authorized.venueId);
    final card = await serializable(session, (tx) async {
      final match = await ItemMatch.db.findById(
        session,
        matchId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final report = await LostReport.db.findById(
        session,
        authorized.reportId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final item = await FoundItem.db.findById(
        session,
        authorized.itemId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (match == null ||
          match.venueId != authorized.venueId ||
          match.state != MatchState.confirmed ||
          report?.status != ReportStatus.possibleMatch ||
          report?.venueId != match.venueId ||
          item?.status != ItemStatus.matched ||
          item?.venueId != match.venueId) {
        throw MatchStateException(
          message:
              'Only a confirmed match awaiting verification can be marked ready',
          matchId: matchId,
        );
      }
      final now = DateTime.now().toUtc();
      final ready = await LostReport.db.updateRow(
        session,
        report!.copyWith(status: ReportStatus.readyForPickup, updatedAt: now),
        transaction: tx,
      );
      await AuditEvent.db.insertRow(
        session,
        AuditEvent(
          venueId: match.venueId,
          entityType: 'report',
          entityId: ready.id!,
          action: 'ready_for_pickup',
          actorAuthUserId: session.authenticated!.authUserId,
          payload: AuditPayload(
            summary: 'Item ready for pickup',
            fromState: report.status.name,
            toState: ready.status.name,
            data: {},
          ),
        ),
        transaction: tx,
      );
      return MatchCard(
        match: match,
        item: StaffViews.item(item!),
        report: StaffViews.report(ready),
        clearLeader: false,
      );
    });
    await _post(session, card.match, DateTime.now().toUtc(), report: true);
    return card;
  }

  Future<ReleaseSummary> release(
    Session session,
    UuidValue itemId,
    ReleaseInput input,
    ByteData? signaturePng,
  ) async {
    final authorized = await _item(session, itemId);
    final prior = await ReleaseRecord.db.findFirstRow(
      session,
      where: (t) => t.itemId.equals(itemId),
    );
    if (prior != null) {
      throw AlreadyReleasedException(
        message: 'Item already released',
        itemId: itemId,
      );
    }
    final error = ReleaseRules.validate(authorized, input, signaturePng);
    if (error != null) {
      throw ReleaseRefusedException(message: error, itemId: itemId);
    }
    // A unique attempt path prevents a losing concurrent call deleting or overwriting the winner's signature.
    final path = signaturePng == null
        ? null
        : 'venues/${authorized.venueId}/releases/$itemId/${const Uuid().v4()}.png';
    if (path != null) {
      await session.storage.storeFile(
        storageId: 'private',
        path: path,
        byteData: signaturePng!,
        options: const StoreFileOptions(
          metadata: FileMetadata(contentType: 'image/png'),
        ),
      );
    }
    late ({ReleaseRecord record, List<ItemMatch> changed, ItemMatch? match})
    result;
    try {
      result = await serializable(session, (tx) async {
        final item = await FoundItem.db.findById(
          session,
          itemId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (await ReleaseRecord.db.findFirstRow(
              session,
              where: (t) => t.itemId.equals(itemId),
              transaction: tx,
            ) !=
            null) {
          throw AlreadyReleasedException(
            message: 'Item already released',
            itemId: itemId,
          );
        }
        if (item == null ||
            item.venueId != authorized.venueId ||
            !{ItemStatus.unclaimed, ItemStatus.matched}.contains(item.status)) {
          throw ReleaseRefusedException(
            message: 'Item is not on the shelf',
            itemId: itemId,
          );
        }
        final validation = ReleaseRules.validate(item, input, signaturePng);
        if (validation != null) {
          throw ReleaseRefusedException(message: validation, itemId: itemId);
        }
        ItemMatch? match;
        LostReport? report;
        if (input.matchId != null) {
          match = await ItemMatch.db.findById(
            session,
            input.matchId!,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          );
          if (match == null ||
              match.venueId != item.venueId ||
              match.itemId != itemId ||
              match.state != MatchState.confirmed ||
              item.status != ItemStatus.matched) {
            throw MatchStateException(
              message: 'A confirmed reservation for this item is required',
              matchId: input.matchId!,
            );
          }
          report = await LostReport.db.findById(
            session,
            match.reportId,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          );
          if (report == null ||
              report.venueId != item.venueId ||
              !{
                ReportStatus.possibleMatch,
                ReportStatus.readyForPickup,
              }.contains(report.status)) {
            throw MatchStateException(
              message: 'Report is not awaiting pickup',
              matchId: match.id!,
            );
          }
        } else if (item.status == ItemStatus.matched) {
          final reserved = await ItemMatch.db.findFirstRow(
            session,
            where: (t) =>
                t.itemId.equals(itemId) & t.state.equals(MatchState.confirmed),
            transaction: tx,
          );
          final owner = reserved == null
              ? null
              : await LostReport.db.findById(
                  session,
                  reserved.reportId,
                  transaction: tx,
                );
          throw ReleaseRefusedException(
            message:
                'Reserved for report ${owner?.refCode ?? 'at the desk'}; undo that confirmation first',
            itemId: itemId,
          );
        }
        final now = DateTime.now().toUtc();
        final record = await ChildRecords.release(
          session,
          itemId: itemId,
          reportId: report?.id,
          claimantName: ReleaseRules.clean(input.claimantName),
          idTypeSeen: input.idTypeSeen,
          detailsMatched: input.detailsMatched,
          describedBeforeViewing: input.describedBeforeViewing,
          releasedByAuthUserId: session.authenticated!.authUserId,
          thirdPartyAuthorisationNote: input.thirdParty
              ? ReleaseRules.clean(input.thirdPartyAuthorisationNote!)
              : null,
          signaturePath: path,
          transaction: tx,
        );
        await FoundItem.db.updateRow(
          session,
          item.copyWith(status: ItemStatus.claimed, updatedAt: now),
          transaction: tx,
        );
        if (report != null) {
          await LostReport.db.updateRow(
            session,
            report.copyWith(
              status: ReportStatus.returned,
              closedAt: now,
              updatedAt: now,
            ),
            transaction: tx,
          );
        }
        final changed = await ItemMatch.db.find(
          session,
          where: (t) =>
              t.venueId.equals(item.venueId) &
              t.state.equals(MatchState.pending) &
              (t.itemId.equals(itemId) |
                  (report == null
                      ? Constant.bool(false)
                      : t.reportId.equals(report.id!))),
          transaction: tx,
        );
        for (final other in changed) {
          await ItemMatch.db.updateRow(
            session,
            other.copyWith(state: MatchState.superseded, updatedAt: now),
            transaction: tx,
          );
        }
        await AuditEvent.db.insertRow(
          session,
          AuditEvent(
            venueId: item.venueId,
            entityType: 'item',
            entityId: itemId,
            action: 'released',
            actorAuthUserId: session.authenticated!.authUserId,
            payload: AuditPayload(
              summary: 'Item returned to claimant',
              fromState: item.status.name,
              toState: 'claimed',
              data: {
                'idTypeSeen': input.idTypeSeen,
                'detailsMatched': '${input.detailsMatched}',
                'thirdParty': '${input.thirdParty}',
                if (report != null) 'reportRefCode': report.refCode,
              },
            ),
          ),
          transaction: tx,
        );
        if (report != null) {
          await AuditEvent.db.insertRow(
            session,
            AuditEvent(
              venueId: item.venueId,
              entityType: 'report',
              entityId: report.id!,
              action: 'returned',
              actorAuthUserId: session.authenticated!.authUserId,
              payload: AuditPayload(
                summary: 'Reported item returned',
                fromState: report.status.name,
                toState: 'returned',
                data: {'itemRefCode': item.refCode},
              ),
            ),
            transaction: tx,
          );
        }
        return (record: record, changed: changed, match: match);
      });
    } catch (_) {
      if (path != null) {
        await session.storage.deleteFile(storageId: 'private', path: path);
      }
      rethrow;
    }
    final now = DateTime.now().toUtc();
    await session.messages.postMessage(
      'venue_${authorized.venueId}',
      DeskEvent(
        kind: 'itemStatus',
        venueId: authorized.venueId,
        itemId: itemId,
        at: now,
      ),
    );
    if (result.match != null) {
      await _post(session, result.match!, now, report: true);
    }
    for (final changed in result.changed) {
      await _post(session, changed, now);
    }
    return _summary(session, result.record);
  }

  Future<ReleaseSummary?> releaseRecord(
    Session session,
    UuidValue itemId,
  ) async {
    await _item(session, itemId);
    final record = await ReleaseRecord.db.findFirstRow(
      session,
      where: (t) => t.itemId.equals(itemId),
    );
    return record == null ? null : _summary(session, record);
  }

  Future<String?> signatureUrl(Session session, UuidValue itemId) async {
    final summary = await releaseRecord(session, itemId);
    final path = summary?.record.signaturePath;
    if (path == null ||
        !await session.storage.fileExists(storageId: 'private', path: path)) {
      return null;
    }
    return (await session.storage.temporaryDownloadUrl(
      storageId: 'private',
      path: path,
      options: const TemporaryDownloadUrlOptions(
        expirationDuration: Duration(minutes: 10),
      ),
    )).toString();
  }

  Future<ReleaseSummary> _summary(Session session, ReleaseRecord record) async {
    final membership = await StaffMembership.db.findFirstRow(
      session,
      where: (t) =>
          t.venueId.equals(record.venueId) &
          t.authUserId.equals(record.releasedByAuthUserId),
    );
    final report = record.reportId == null
        ? null
        : await LostReport.db.findById(session, record.reportId!);
    return ReleaseSummary(
      record: record,
      releasedByName: membership?.displayName ?? 'Former staff member',
      reportRefCode: report?.refCode,
    );
  }

  Future<void> _post(
    Session session,
    ItemMatch match,
    DateTime at, {
    bool report = false,
  }) async {
    await session.messages.postMessage(
      'venue_${match.venueId}',
      DeskEvent(
        kind: 'matchStatus',
        venueId: match.venueId,
        matchId: match.id,
        itemId: match.itemId,
        reportId: match.reportId,
        at: at,
      ),
    );
    if (report) {
      await session.messages.postMessage(
        'venue_${match.venueId}',
        DeskEvent(
          kind: 'reportStatus',
          venueId: match.venueId,
          reportId: match.reportId,
          at: at,
        ),
      );
    }
  }
}
