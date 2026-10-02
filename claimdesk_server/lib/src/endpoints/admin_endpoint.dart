import 'dart:isolate';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';

import '../services/seed_service.dart';
import '../services/demo_inventory_service.dart';
import '../generated/protocol.dart';
import '../jobs/job_queue.dart';
import '../jobs/job_wakeup.dart';
import '../ai/image_prep.dart';
import '../ai/providers.dart';
import '../services/child_records.dart';
import '../services/upload_tickets.dart';

Future<PreparedImage?> _prepareSeedPhoto(Uint8List bytes) =>
    Isolate.run(() => prepareImage(bytes));

class AdminEndpoint extends Endpoint {
  @override
  bool get logSessions => false;
  Future<FoundItem> attachSeedPhoto(
    Session session,
    String secret,
    String refCode,
    ByteData jpeg, {
    bool recaption = true,
    bool force = false,
  }) async {
    _authorize(session, secret);
    final venue = await Venue.db.findFirstRow(
      session,
      where: (t) => t.slug.equals('hawrys-demo'),
    );
    if (venue == null ||
        !RegExp(
          r'^(SEED(0[1-9]|[12][0-9]|30)|DEMORE|DEMOEX)$',
        ).hasMatch(refCode)) {
      throw ArgumentError('Demo seed item unavailable');
    }
    final input = await FoundItem.db.findFirstRow(
      session,
      where: (t) => t.venueId.equals(venue.id!) & t.refCode.equals(refCode),
    );
    if (input == null) throw ArgumentError('Demo seed item unavailable');
    if (input.photoPath != null && !force) return input;
    final bytes = jpeg.buffer.asUint8List(
      jpeg.offsetInBytes,
      jpeg.lengthInBytes,
    );
    final prepared = await _prepareSeedPhoto(bytes);
    if (prepared == null) {
      throw ArgumentError('Image format, size or dimensions are unsupported');
    }
    final updated = await session.db.transaction((tx) async {
      final item = await FoundItem.db.findById(
        session,
        input.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (item == null || item.venueId != venue.id) {
        throw ArgumentError('Demo seed item unavailable');
      }
      if (item.photoPath != null && !force) return item;
      if (recaption &&
          item.status != ItemStatus.unclaimed &&
          item.status != ItemStatus.captioning) {
        throw StateError('Only open, unreserved items can be recaptioned');
      }
      final path = UploadTickets.path(item.venueId, item.id!);
      final thumb = 'venues/${item.venueId}/items/${item.id}.thumb.jpg';
      const options = StoreFileOptions(
        metadata: FileMetadata(contentType: 'image/jpeg'),
      );
      await session.storage.storeFile(
        storageId: 'private',
        path: path,
        byteData: ByteData.sublistView(prepared.jpeg),
        options: options,
      );
      await session.storage.storeFile(
        storageId: 'private',
        path: thumb,
        byteData: ByteData.sublistView(prepared.thumb),
        options: options,
      );
      final row = await FoundItem.db.updateRow(
        session,
        recaption
            ? item.copyWith(
                photoPath: path,
                thumbPath: thumb,
                status: ItemStatus.captioning,
                embedding: null,
                embeddingModel: null,
                updatedAt: DateTime.now().toUtc(),
              )
            : item.copyWith(photoPath: path, thumbPath: thumb),
        transaction: tx,
      );
      if (recaption) {
        await ChildRecords.itemWork(
          session,
          itemId: item.id!,
          kind: 'caption_item',
          identifier: 'caption_${item.id}',
          data: {'promptVersion': Providers.config.captionPromptVersion},
          maxAttempts: 2,
          transaction: tx,
        );
      }
      await AuditEvent.db.insertRow(
        session,
        AuditEvent(
          venueId: item.venueId,
          entityType: 'item',
          entityId: item.id!,
          action: 'photo_attached',
          payload: AuditPayload(
            summary: 'Synthetic demo photo attached',
            data: {'recaption': recaption.toString()},
          ),
        ),
        transaction: tx,
      );
      return row;
    });
    JobWakeup.notify(session);
    return updated;
  }

  Future<WorkItem> runNightly(Session session, String secret) async {
    _authorize(session, secret);
    return JobQueue.enqueue(
      session,
      kind: 'nightly',
      payload: WorkPayload(data: {}),
      identifier: 'nightly_manual_${DateTime.now().microsecondsSinceEpoch}',
      maxAttempts: 3,
    );
  }

  Future<int> seedDemoItems(Session session, String secret) async {
    _authorize(session, secret);
    return DemoInventoryService.items(session);
  }

  Future<int> seedDemoReports(Session session, String secret) async {
    _authorize(session, secret);
    return DemoInventoryService.reports(session);
  }

  void _authorize(Session session, String secret) {
    if (!SeedService.acceptsSecret(secret, session.passwords['seedSecret'])) {
      throw Exception('Demo seed access denied');
    }
  }

  Future<({UuidValue venueId, UuidValue supervisorId, UuidValue staffId})>
  seedDemo(
    Session session,
    String secret,
  ) async {
    if (!SeedService.acceptsSecret(secret, session.passwords['seedSecret'])) {
      throw Exception('Demo seed access denied');
    }
    return SeedService.seedDemo(session);
  }
}
