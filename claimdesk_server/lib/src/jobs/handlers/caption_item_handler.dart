import 'dart:isolate';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../../ai/image_prep.dart';
import '../../ai/providers.dart';
import '../../ai/template_captioner.dart';
import '../../ai/text_template.dart';
import '../../generated/protocol.dart';
import '../../policy/retention.dart';
import '../../services/child_records.dart';
import '../job_handler.dart';

Future<PreparedImage?> _prepare(Uint8List bytes) =>
    Isolate.run(() => prepareImage(bytes));

class CaptionItemHandler extends JobHandler {
  @override
  String get kind => 'caption_item';
  @override
  Future<void> run(Session session, WorkItem job) async {
    var item = await FoundItem.db.findById(session, job.payload.entityId!);
    if (item == null || item.venueId != job.venueId) return;
    // Resume a crash after the attribute commit by finishing only the embedding.
    if (item.status == ItemStatus.unclaimed &&
        item.attributes != null &&
        item.embedding == null) {
      await embedItem(session, job, item);
      await _post(session, item, 'itemStatus');
      return;
    }
    if (item.status != ItemStatus.captioning ||
        !await JobClaim.current(session, job)) {
      return;
    }
    final version =
        job.payload.data['promptVersion'] ??
        Providers.config.captionPromptVersion;
    Uint8List bytes = Uint8List(0);
    if (item.photoPath != null) {
      final data = await session.storage.retrieveFile(
        storageId: 'private',
        path: item.photoPath!,
      );
      final preparationTimer = Stopwatch()..start();
      final prepared = await _prepare(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      session.log(
        'Caption image prepared in ${preparationTimer.elapsedMilliseconds} ms',
      );
      if (prepared == null) {
        if (await JobClaim.current(session, job)) {
          await ChildRecords.caption(
            session,
            itemId: item.id!,
            provider: 'image',
            modelId: 'none',
            promptVersion: version,
            outcome: 'invalid_image',
            latencyMs: 0,
            errorMessage: 'Image format, size or dimensions are unsupported',
          );
          await _post(session, item, 'captionFailed');
        }
        throw const FormatException('Invalid image');
      }
      if (!await JobClaim.current(session, job)) return;
      bytes = prepared.jpeg;
      final thumb = 'venues/${item.venueId}/items/${item.id}.thumb.jpg';
      const options = StoreFileOptions(
        metadata: FileMetadata(contentType: 'image/jpeg'),
      );
      final storageTimer = Stopwatch()..start();
      await Future.wait([
        session.storage.storeFile(
          storageId: 'private',
          path: item.photoPath!,
          byteData: ByteData.sublistView(bytes),
          options: options,
        ),
        session.storage.storeFile(
          storageId: 'private',
          path: thumb,
          byteData: ByteData.sublistView(prepared.thumb),
          options: options,
        ),
      ]);
      session.log(
        'Caption images stored in ${storageTimer.elapsedMilliseconds} ms',
      );
      final old = item;
      final changed = await FoundItem.db.updateWhere(
        session,
        columnValues: (t) => [t.thumbPath(thumb)],
        where: (t) =>
            t.id.equals(old.id!) & t.status.equals(ItemStatus.captioning),
      );
      if (changed.isEmpty) return;
      item = changed.single;
      await _post(session, item, 'itemStatus');
    }
    final result =
        await (item.photoPath == null
                ? TemplateCaptioner()
                : Providers.captioner)
            .describe(
              bytes,
              promptVersion: version,
              hints: CaptionHints.fromAttributes(item.attributes),
            );
    final attrs = result.attributes;
    if (attrs == null) throw StateError('Caption chain returned no attributes');
    final safe = protectAttributes(attrs);
    final snapshot = item;
    final committed = await session.db.transaction((tx) async {
      // Match the endpoint lock order; metadata edits can coexist with captioning.
      final current = await FoundItem.db.findById(
        session,
        snapshot.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null || current.status != ItemStatus.captioning) {
        return null;
      }
      if (!await JobClaim.current(session, job, transaction: tx, lock: true)) {
        return null;
      }
      final venue = await Venue.db.findById(
        session,
        current.venueId,
        transaction: tx,
      );
      if (venue == null) return null;
      for (final attempt in result.attempts) {
        await ChildRecords.caption(
          session,
          itemId: current.id!,
          provider: attempt.provider,
          modelId: attempt.modelId,
          promptVersion: version,
          outcome: attempt.outcome,
          latencyMs: attempt.latencyMs,
          inputTokens: attempt.inputTokens,
          outputTokens: attempt.outputTokens,
          errorMessage: attempt.errorMessage,
          transaction: tx,
        );
      }
      final dates = retentionDates(current, venue, safe.category);
      final updated = await FoundItem.db.updateRow(
        session,
        current.copyWith(
          attributes: safe,
          captionText: TextTemplate.render(safe),
          restricted: restrictedAttributes(safe),
          status: ItemStatus.unclaimed,
          embedding: null,
          embeddingModel: null,
          holdUntil: dates.holdUntil,
          handoffDueAt: dates.handoffDueAt,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
      await AuditEvent.db.insertRow(
        session,
        AuditEvent(
          venueId: current.venueId,
          entityType: 'item',
          entityId: current.id!,
          action: 'captioned',
          payload: AuditPayload(
            summary: 'Item captioned',
            fromState: 'captioning',
            toState: 'unclaimed',
            data: {},
          ),
        ),
        transaction: tx,
      );
      return updated;
    });
    if (committed != null) {
      await embedItem(session, job, committed);
      await _post(session, committed, 'itemStatus');
    }
  }

  @override
  Future<void> failed(Session session, WorkItem job) async {
    final item = await FoundItem.db.findById(session, job.payload.entityId!);
    if (item != null &&
        item.venueId == job.venueId &&
        item.status == ItemStatus.captioning) {
      await _post(session, item, 'captionFailed');
    }
  }

  static Future<void> _post(Session s, FoundItem item, String kind) =>
      s.messages.postMessage(
        'venue_${item.venueId}',
        DeskEvent(
          kind: kind,
          venueId: item.venueId,
          itemId: item.id,
          at: DateTime.now().toUtc(),
        ),
      );
}

Future<void> embedItem(
  Session session,
  WorkItem job,
  FoundItem item, {
  bool retryFailure = false,
}) async {
  if (item.captionText == null) return;
  try {
    final values = await Providers.embedder.embedDocument(item.captionText!);
    if (values.length != 1536 || values.any((v) => !v.isFinite)) {
      throw const FormatException('Invalid embedding');
    }
    await session.db.transaction((tx) async {
      final current = await FoundItem.db.findById(
        session,
        item.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (current == null ||
          current.captionText != item.captionText ||
          current.status == ItemStatus.captioning) {
        return;
      }
      if (!await JobClaim.current(session, job, transaction: tx, lock: true)) {
        return;
      }
      await FoundItem.db.updateWhere(
        session,
        columnValues: (t) => [
          t.embedding(Vector(values)),
          t.embeddingModel(Providers.embedder.modelId),
        ],
        where: (t) =>
            t.id.equals(item.id!) &
            t.captionText.equals(item.captionText) &
            t.status.notEquals(ItemStatus.captioning),
        transaction: tx,
      );
    });
  } catch (_) {
    session.log('Item embedding unavailable; retained caption for later retry');
    if (retryFailure) rethrow;
  }
}
