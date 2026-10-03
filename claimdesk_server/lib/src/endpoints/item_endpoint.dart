import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../matching/match_jobs.dart';
import '../jobs/job_wakeup.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../access/venue_guard.dart';
import '../ai/providers.dart';
import '../ai/prompts/caption_v1.dart';
import '../ai/text_template.dart';
import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import '../policy/retention.dart';
import '../services/child_records.dart';
import '../services/upload_tickets.dart';
import '../services/photo_upload_relay.dart';
import '../services/item_attention.dart';
import '../services/staff_views.dart';

class ItemEndpoint extends Endpoint with VenueGuard {
  Future<PhotoUploadTicket> requestPhotoUpload(
    Session session,
    UuidValue venueId,
    String contentType,
  ) async {
    await requireMembership(session, venueId);
    if (!['image/jpeg', 'image/png', 'image/webp'].contains(contentType)) {
      throw ArgumentError('Unsupported image type');
    }
    final id = UuidValue.fromString(const Uuid().v7());
    final path = UploadTickets.path(venueId, id);
    final expires = DateTime.now().toUtc().add(const Duration(minutes: 10));
    final proof = UploadTickets.sign(session, venueId, id, expires);
    return PhotoUploadTicket(
      itemId: id,
      path: path,
      expiresAt: expires,
      proof: proof,
      uploadDescription:
          PhotoUploadRelay.description(
            session,
            venueId: venueId,
            itemId: id,
            expires: expires,
            proof: proof,
            contentType: contentType,
          ) ??
          await session.storage.createUploadDescription(
            storageId: 'private',
            path: path,
            options: UploadOptions(
              maxFileSize: 15 * 1024 * 1024,
              preventOverwrite: true,
              metadata: FileMetadata(contentType: contentType),
            ),
          ),
    );
  }

  Future<FoundItem> createItem(
    Session session,
    UuidValue venueId,
    CreateItemInput input,
  ) async {
    await requireMembership(session, venueId);
    await _checkZone(session, venueId, input.zoneId);
    final attrs = _validateAttributes(
      ItemAttributes(
        category: input.category,
        colours: input.colours ?? [],
        brand: input.brand,
        marks: [],
        description: input.description ?? Taxonomy.label(input.category),
        personalDataKinds: [],
        keywords: [],
        source: 'staff_typed',
      ),
    );
    _bounded(input.privateNotes, 4000);
    _bounded(input.storageBin, 100);
    _bounded(input.finderName, 200);
    final id = input.photoPath == null
        ? UuidValue.fromString(const Uuid().v7())
        : input.itemId;
    if (id == null) throw ArgumentError('Photo upload ticket required');
    if (input.photoPath != null) {
      if (input.photoPath != UploadTickets.path(venueId, id) ||
          !UploadTickets.verify(
            session,
            venueId,
            id,
            input.uploadExpiresAt,
            input.uploadProof,
          )) {
        throw ArgumentError('Invalid upload ticket');
      }
      if (!await session.storage.verifyUpload(
        storageId: 'private',
        path: input.photoPath!,
      )) {
        throw ArgumentError('Photo upload not verified');
      }
    }
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final item = await session.db.transaction((tx) async {
          final item = await FoundItem.db.insertRow(
            session,
            FoundItem(
              id: id,
              venueId: venueId,
              zoneId: input.zoneId,
              status: ItemStatus.captioning,
              refCode: _reference(),
              photoPath: input.photoPath,
              attributes: attrs,
              restricted: restrictedAttributes(attrs),
              valueBand: input.valueBand,
              storageBin: input.storageBin,
              privateNotes: input.privateNotes,
              finderName: input.finderName,
              foundAt: input.foundAt?.toUtc(),
              loggedByAuthUserId: session.authenticated!.authUserId,
            ),
            transaction: tx,
          );
          await AuditEvent.db.insertRow(
            session,
            AuditEvent(
              venueId: item.venueId,
              entityType: 'item',
              entityId: item.id!,
              action: 'created',
              actorAuthUserId: session.authenticated!.authUserId,
              payload: AuditPayload(
                summary: 'Found item recorded',
                toState: 'captioning',
                data: {},
              ),
            ),
            transaction: tx,
          );
          await ChildRecords.itemWork(
            session,
            itemId: item.id!,
            kind: 'caption_item',
            identifier: 'caption_${item.id}',
            data: {'promptVersion': Providers.config.captionPromptVersion},
            maxAttempts: 2,
            transaction: tx,
          );
          return item;
        });
        JobWakeup.notify(session);
        return item;
      } on DatabaseUniqueViolationException catch (error) {
        if (error.constraintName !=
                'found_item__venueId__refCode__unique_idx' ||
            attempt == 4) {
          rethrow;
        }
      }
    }
    throw StateError('Unable to allocate item reference');
  }

  Future<FoundItem> getItem(Session session, UuidValue itemId) async =>
      StaffViews.item(await _authorizedItem(session, itemId));

  Future<List<FoundItem>> listItems(
    Session session,
    UuidValue venueId,
    ItemFilter filter,
  ) async {
    await requireMembership(session, venueId);
    final result = <FoundItem>[];
    final now = DateTime.now().toUtc();
    for (var offset = 0; ; offset += 100) {
      final rows = await FoundItem.db.find(
        session,
        where: (t) => ItemAttention.filter(t, venueId, filter, now),
        orderByList: (t) => [t.foundAt.desc(), t.id.desc()],
        limit: 100,
        offset: offset,
      );
      result.addAll(
        rows.where(
          (r) =>
              filter.category == null ||
              r.attributes?.category == filter.category ||
              (r.attributes != null &&
                  Taxonomy.rollUp(r.attributes!.category) == filter.category),
        ),
      );
      if (result.length >= 100 || rows.length < 100) {
        return result.take(100).map(StaffViews.item).toList();
      }
    }
  }

  Future<String?> photoUrl(
    Session session,
    UuidValue itemId, {
    bool thumb = false,
  }) async {
    final item = await _authorizedItem(session, itemId);
    final path = thumb ? item.thumbPath : item.photoPath;
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

  Future<FoundItem> updateItem(
    Session session,
    UuidValue itemId,
    ItemPatch patch,
  ) async {
    final allowed = await _authorizedItem(session, itemId);
    if (patch.clearZone && patch.zoneId != null) {
      throw ArgumentError('Conflicting zone patch');
    }
    await _checkZone(session, allowed.venueId, patch.zoneId);
    _bounded(patch.storageBin, 100);
    _bounded(patch.privateNotes, 4000);
    final attrs = patch.attributes == null
        ? null
        : _validateAttributes(
            patch.attributes!.copyWith(source: 'staff_typed'),
          );
    final updated = await session.db.transaction((tx) async {
      final row = (await FoundItem.db.findById(
        session,
        itemId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      final venue = (await Venue.db.findById(
        session,
        row.venueId,
        transaction: tx,
      ))!;
      var item = row.copyWith(
        attributes: attrs ?? row.attributes,
        valueBand: patch.valueBand ?? row.valueBand,
        storageBin: patch.clearStorageBin
            ? null
            : patch.storageBin ?? row.storageBin,
        privateNotes: patch.clearPrivateNotes
            ? null
            : patch.privateNotes ?? row.privateNotes,
        zoneId: patch.clearZone ? null : patch.zoneId ?? row.zoneId,
        updatedAt: DateTime.now().toUtc(),
      );
      if (attrs != null) {
        item = item.copyWith(
          captionText: TextTemplate.render(attrs),
          restricted: restrictedAttributes(attrs),
          embedding: null,
          embeddingModel: null,
          status: row.status == ItemStatus.captioning
              ? ItemStatus.unclaimed
              : row.status,
        );
      }
      final dates = retentionDates(
        item,
        venue,
        item.attributes?.category ?? 'other',
      );
      item = await FoundItem.db.updateRow(
        session,
        item.copyWith(
          holdUntil: dates.holdUntil,
          handoffDueAt: dates.handoffDueAt,
        ),
        transaction: tx,
      );
      if (attrs != null) {
        await ChildRecords.itemWork(
          session,
          itemId: item.id!,
          kind: 'reembed_item',
          identifier: 'reembed_${item.id}',
          transaction: tx,
        );
        await MatchJobs.item(session, item, transaction: tx);
      }
      await AuditEvent.db.insertRow(
        session,
        AuditEvent(
          venueId: item.venueId,
          entityType: 'item',
          entityId: item.id!,
          action: 'updated',
          actorAuthUserId: session.authenticated!.authUserId,
          payload: AuditPayload(summary: 'Staff updated item', data: {}),
        ),
        transaction: tx,
      );
      return item;
    });
    if (attrs != null) JobWakeup.notify(session);
    await session.messages.postMessage(
      'venue_${updated.venueId}',
      DeskEvent(
        kind: 'itemStatus',
        venueId: updated.venueId,
        itemId: updated.id,
        at: DateTime.now().toUtc(),
      ),
    );
    return updated;
  }

  Future<WorkItem> recaption(Session session, UuidValue itemId) async {
    await _authorizedItem(session, itemId);
    final job = await session.db.transaction((tx) async {
      final item = (await FoundItem.db.findById(
        session,
        itemId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      if (item.status != ItemStatus.unclaimed) {
        throw StateError('Only unclaimed items can be recaptioned');
      }
      await FoundItem.db.updateRow(
        session,
        item.copyWith(
          status: ItemStatus.captioning,
          embedding: null,
          embeddingModel: null,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
      return ChildRecords.itemWork(
        session,
        itemId: itemId,
        kind: 'caption_item',
        identifier: 'caption_$itemId',
        data: {'promptVersion': Providers.config.captionPromptVersion},
        maxAttempts: 2,
        transaction: tx,
      );
    });
    JobWakeup.notify(session);
    return job;
  }

  Future<List<CaptionRun>> captionRuns(
    Session session,
    UuidValue itemId,
  ) async {
    await _authorizedItem(session, itemId);
    return CaptionRun.db.find(
      session,
      where: (t) => t.itemId.equals(itemId),
      orderBy: (t) => t.createdAt,
    );
  }

  Future<FoundItem> _authorizedItem(Session s, UuidValue id) async {
    final item = await FoundItem.db.findById(s, id);
    if (item == null) throw ArgumentError('Item unavailable');
    await requireMembership(s, item.venueId);
    return item;
  }

  Future<void> _checkZone(Session s, UuidValue venue, UuidValue? id) async {
    if (id == null) return;
    final zone = await Zone.db.findById(s, id);
    if (zone == null || zone.venueId != venue) {
      throw ArgumentError('Zone does not belong to venue');
    }
  }

  static void _bounded(String? value, int maximum) {
    if (value != null && value.length > maximum) {
      throw ArgumentError('Field too long');
    }
  }

  static ItemAttributes _validateAttributes(ItemAttributes a) {
    if (!Taxonomy.groups.containsKey(a.category) ||
        a.colours.length > 3 ||
        a.colours.any((c) => !Taxonomy.colours.contains(c)) ||
        a.personalDataKinds.any((k) => !personalDataKinds.contains(k)) ||
        a.marks.length > 5 ||
        a.description.trim().isEmpty ||
        a.description.trim().split(RegExp(r'\s+')).length > 60) {
      throw ArgumentError('Invalid item attributes');
    }
    _bounded(a.description, 2000);
    _bounded(a.brand, 200);
    _bounded(a.material, 200);
    for (final mark in a.marks) {
      _bounded(mark, 300);
    }
    return protectAttributes(
      a.copyWith(
        keywords: [],
        language: null,
        modelId: null,
        promptVersion: null,
      ),
    );
  }

  static String _reference() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => alphabet[r.nextInt(alphabet.length)]).join();
  }
}
