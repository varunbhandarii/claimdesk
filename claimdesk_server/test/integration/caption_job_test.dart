import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:claimdesk_server/src/ai/claude_captioner.dart';
import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/ai/providers.dart';
import 'package:claimdesk_server/src/ai/template_captioner.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/handlers/caption_item_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/reembed_item_handler.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

class _DelayedCaptioner extends FakeCaptioner {
  _DelayedCaptioner() : super(fixtureName: 'umbrella');
  final entered = Completer<void>(), release = Completer<void>();
  @override
  Future<CaptionResult> describe(
    Uint8List bytes, {
    required String promptVersion,
    CaptionHints? hints,
  }) async {
    entered.complete();
    await release.future;
    return super.describe(bytes, promptVersion: promptVersion, hints: hints);
  }
}

void main() {
  withServerpod('Given photo captioning', (builder, endpoints) {
    setUp(() => clearWorkerTestData(builder.build()));
    tearDown(() => clearWorkerTestData(builder.build()));
    late Session s;
    late Venue venue;
    late JobWorker worker;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          authUserId: actorId,
          venueId: venue.id!,
          displayName: 'Staff',
        ),
      );
      Providers.captioner = ChainCaptioner(
        FakeCaptioner(fixtureName: 'umbrella'),
      );
      Providers.embedder = FakeEmbedder();
      worker = JobWorker(
        s.serverpod,
        handlers: [CaptionItemHandler(), ReembedItemHandler()],
        renewLeases: false,
      );
    });
    Future<FoundItem> input({bool invalid = false}) async {
      final item = await makeItem(s, venue.id!);
      final path = 'venues/${venue.id}/items/${item.id}.jpg';
      await s.storage.storeFile(
        storageId: 'private',
        path: path,
        byteData: ByteData.sublistView(
          invalid
              ? Uint8List.fromList([1, 2, 3])
              : Uint8List.fromList(
                  img.encodeJpg(img.Image(width: 360, height: 240)),
                ),
        ),
      );
      final row = await FoundItem.db.updateRow(
        s,
        item.copyWith(
          status: ItemStatus.captioning,
          photoPath: path,
          attributes: ItemAttributes(
            category: 'umbrella',
            colours: ['black'],
            brand: 'Staff brand',
            marks: [],
            description: 'Black umbrella with a curved handle',
            personalDataKinds: [],
            keywords: [],
            source: 'staff_typed',
          ),
        ),
      );
      await ChildRecords.itemWork(
        s,
        itemId: item.id!,
        kind: 'caption_item',
        identifier: 'caption_${item.id}',
        maxAttempts: 2,
      );
      return row;
    }

    test(
      'a photo becomes a captioned embedded item and broadcasts its status',
      () async {
        final item = await input();
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        await flushEventQueue();
        await worker.tick(s);
        await flushEventQueue();
        final row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.status, ItemStatus.unclaimed);
        expect(row.attributes!.category, 'umbrella');
        expect(row.restricted, false);
        expect(row.captionText, contains('wooden handle'));
        expect(row.embedding!.toList(), hasLength(1536));
        expect(row.thumbPath, isNotNull);
        expect(
          await s.storage.fileExists(
            storageId: 'private',
            path: row.thumbPath!,
          ),
          true,
        );
        expect(row.holdUntil, row.foundAt.add(const Duration(days: 14)));
        final run = (await CaptionRun.db.find(s)).single;
        expect(run.outcome, 'ok');
        expect(run.venueId, row.venueId);
        expect(run.modelId, 'fake-caption');
        expect(run.promptVersion, 'caption_v1');
        expect(run.inputTokens, 10);
        expect(events, hasLength(2));
        expect(events.every((event) => event.itemId == row.id), true);
        expect(events.every((event) => event.kind == 'itemStatus'), true);
        await sub.cancel();
        await worker.tick(s);
        expect(await CaptionRun.db.count(s), 1);
      },
    );
    test(
      'personal data is removed from attributes and embedding text',
      () async {
        Providers.captioner = ChainCaptioner(
          FakeCaptioner(fixtureName: 'mock_id_card'),
        );
        final item = await input();
        await worker.tick(s);
        final row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.restricted, true);
        expect(row.attributes!.description, 'id card or pass');
        expect(row.attributes!.marks, isEmpty);
        expect(row.attributes!.brand, isNull);
        expect(row.captionText!.split('\n'), hasLength(1));
        expect(RegExp(r'\d').hasMatch(row.captionText!), false);
      },
    );
    test(
      'provider failure preserves staff hints with a recorded template fallback',
      () async {
        Providers.captioner = ChainCaptioner(FakeCaptioner(failures: 3));
        final item = await input();
        await worker.tick(s);
        final row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.status, ItemStatus.unclaimed);
        expect(row.attributes!.source, 'staff_typed');
        expect(row.attributes!.brand, 'Staff brand');
        expect(row.attributes!.description, contains('curved handle'));
        expect((await CaptionRun.db.find(s)).map((r) => r.outcome), [
          'transport_error',
          'fallback_template',
        ]);
      },
    );
    for (final refusal in [true, false]) {
      test(
        '${refusal ? 'refused' : 'invalid'} vision output falls back without blocking intake',
        () async {
          Providers.captioner = ChainCaptioner(
            ClaudeCaptioner(
              apiKey: 'test',
              delay: (_) async {},
              client: MockClient(
                (_) async => http.Response(
                  jsonEncode({
                    'model': 'claude-opus-5-5',
                    'stop_reason': refusal ? 'refusal' : 'end_turn',
                    'content': [
                      {'type': 'text', 'text': '{}'},
                    ],
                  }),
                  200,
                ),
              ),
            ),
          );
          final item = await input();
          await worker.tick(s);
          expect(
            (await FoundItem.db.findById(s, item.id!))!.status,
            ItemStatus.unclaimed,
          );
          final runs = await CaptionRun.db.find(s);
          expect(
            runs.map((r) => r.outcome),
            refusal
                ? ['refused', 'fallback_template']
                : ['invalid_json', 'invalid_json', 'fallback_template'],
          );
        },
      );
    }
    test(
      'invalid image retries once then remains available for manual correction',
      () async {
        final item = await input(invalid: true);
        await worker.tick(s);
        final job = (await WorkItem.db.find(s)).single;
        final retry = JobWorker(
          s.serverpod,
          handlers: [CaptionItemHandler()],
          clock: () => job.runAt,
          renewLeases: false,
        );
        await retry.tick(s);
        await retry.tick(s);
        expect(
          (await FoundItem.db.findById(s, item.id!))!.status,
          ItemStatus.captioning,
        );
        expect(
          (await WorkItem.db.findById(s, job.id!))!.state,
          WorkState.failed,
        );
        expect((await CaptionRun.db.find(s)).map((r) => r.outcome), [
          'invalid_image',
          'invalid_image',
        ]);
      },
    );
    test(
      'embedding outage preserves a usable caption and recovery avoids recaptioning',
      () async {
        Providers.embedder = FakeEmbedder(fail: true);
        final item = await input();
        await worker.tick(s);
        var row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.status, ItemStatus.unclaimed);
        expect(row.embedding, isNull);
        Providers.embedder = FakeEmbedder();
        await ChildRecords.itemWork(
          s,
          itemId: item.id!,
          kind: 'caption_item',
          identifier: 'caption_${item.id}',
        );
        await worker.tick(s);
        row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.embedding, isNotNull);
        expect(await CaptionRun.db.count(s), 1);
      },
    );
    test(
      'metadata edits during captioning preserve both the edit and caption',
      () async {
        final slow = _DelayedCaptioner();
        Providers.captioner = slow;
        final item = await input();
        final task = worker.tick(s);
        await slow.entered.future;
        final member = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            actorId.uuid,
            {},
          ),
        );
        await endpoints.item.updateItem(
          member,
          item.id!,
          ItemPatch(storageBin: 'Bin 2'),
        );
        slow.release.complete();
        await task;
        final row = (await FoundItem.db.findById(s, item.id!))!;
        expect(row.status, ItemStatus.unclaimed);
        expect(row.storageBin, 'Bin 2');
        expect(row.embedding, isNotNull);
      },
    );
    test('a staff correction wins over an in-flight caption', () async {
      final slow = _DelayedCaptioner();
      Providers.captioner = slow;
      final item = await input();
      final task = worker.tick(s);
      await slow.entered.future;
      final member = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          actorId.uuid,
          {},
        ),
      );
      await endpoints.item.updateItem(
        member,
        item.id!,
        ItemPatch(
          attributes: item.attributes!.copyWith(
            category: 'backpack',
            description: 'A staff-corrected backpack',
          ),
        ),
      );
      slow.release.complete();
      await task;
      final row = (await FoundItem.db.findById(s, item.id!))!;
      expect(row.attributes!.category, 'backpack');
      expect(row.embedding, isNotNull);
      expect(await CaptionRun.db.count(s), 0);
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
