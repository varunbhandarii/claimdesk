import 'dart:typed_data';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/endpoints/admin_endpoint.dart';
import 'package:claimdesk_server/src/services/demo_inventory_service.dart';
import 'package:image/image.dart' as img;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

void main() {
  withServerpod('Synthetic seed photo attachment', (builder, _) {
    late Session s;
    late String secret;
    final endpoint = AdminEndpoint();
    final jpeg = ByteData.sublistView(
      Uint8List.fromList(img.encodeJpg(img.Image(width: 80, height: 50))),
    );
    setUp(() async {
      s = builder.build();
      await clearWorkerTestData(s);
      configureTestAuth();
      await DemoInventoryService.items(s);
      await DemoInventoryService.reports(s);
      secret = s.passwords['seedSecret']!;
      await WorkItem.db.deleteWhere(s, where: (_) => Constant.bool(true));
      await AuditEvent.db.deleteWhere(s, where: (_) => Constant.bool(true));
    });
    tearDown(() => clearWorkerTestData(s));
    test(
      'secret, reference, venue and image content are checked before writes',
      () async {
        await expectLater(
          endpoint.attachSeedPhoto(s, 'wrong', 'SEED01', jpeg),
          throwsException,
        );
        await expectLater(
          endpoint.attachSeedPhoto(s, secret, 'UNKNOWN', jpeg),
          throwsArgumentError,
        );
        await expectLater(
          endpoint.attachSeedPhoto(s, secret, 'SEED01', ByteData(3)),
          throwsArgumentError,
        );
        await expectLater(
          endpoint.attachSeedPhoto(
            s,
            secret,
            'SEED01',
            ByteData(15 * 1024 * 1024 + 1),
          ),
          throwsArgumentError,
        );
        final otherVenue = await makeVenue(s);
        await makeItem(s, otherVenue.id!, refCode: 'SEED01');
        final attached = await endpoint.attachSeedPhoto(
          s,
          secret,
          'SEED01',
          jpeg,
        );
        expect(attached.venueId, isNot(otherVenue.id));
      },
    );
    test(
      'open item attaches both private files and queues caption exactly once',
      () async {
        final row = await endpoint.attachSeedPhoto(s, secret, 'SEED01', jpeg);
        expect(row.status, ItemStatus.captioning);
        expect(row.embedding, isNull);
        expect(row.photoPath, 'venues/${row.venueId}/items/${row.id}.jpg');
        for (final path in [row.photoPath!, row.thumbPath!]) {
          expect(
            await s.storage.fileExists(storageId: 'private', path: path),
            true,
          );
        }
        final job = (await WorkItem.db.find(s)).single;
        expect(job.kind, 'caption_item');
        expect(job.payload.entityId, row.id);
        expect(job.venueId, row.venueId);
        expect(job.identifier, 'caption_${row.id}');
        final audit = (await AuditEvent.db.find(s)).single;
        expect(audit.action, 'photo_attached');
        expect(audit.payload!.data['recaption'], 'true');
        final second = await endpoint.attachSeedPhoto(
          s,
          secret,
          'SEED01',
          ByteData(0),
        );
        expect(second.updatedAt, row.updatedAt);
        expect(await WorkItem.db.count(s), 1);
        expect(await AuditEvent.db.count(s), 1);
      },
    );
    test(
      'terminal attachment preserves attributes, lifecycle and receipt without jobs',
      () async {
        final before = (await FoundItem.db.find(
          s,
          where: (t) => t.refCode.equals('DEMORE'),
        )).single;
        final receipts = await ReleaseRecord.db.find(s);
        final row = await endpoint.attachSeedPhoto(
          s,
          secret,
          'DEMORE',
          jpeg,
          recaption: false,
        );
        expect(row.status, before.status);
        expect(row.attributes!.toJson(), before.attributes!.toJson());
        expect(row.updatedAt, before.updatedAt);
        expect(row.holdUntil, before.holdUntil);
        expect(await WorkItem.db.count(s), 0);
        expect(
          (await ReleaseRecord.db.find(s)).map((r) => r.toJson()),
          receipts.map((r) => r.toJson()),
        );
        expect(
          (await AuditEvent.db.find(s)).single.payload!.data['recaption'],
          'false',
        );
        await DemoInventoryService.items(s);
        expect(
          (await FoundItem.db.findById(s, row.id!))!.photoPath,
          row.photoPath,
        );
      },
    );
    test(
      'recaption refuses terminal or reserved rows even with force',
      () async {
        await expectLater(
          endpoint.attachSeedPhoto(s, secret, 'DEMORE', jpeg),
          throwsStateError,
        );
        final row = (await FoundItem.db.find(
          s,
          where: (t) => t.refCode.equals('SEED01'),
        )).single;
        await FoundItem.db.updateRow(
          s,
          row.copyWith(status: ItemStatus.matched),
        );
        await expectLater(
          endpoint.attachSeedPhoto(s, secret, 'SEED01', jpeg, force: true),
          throwsStateError,
        );
        expect(await WorkItem.db.count(s), 0);
      },
    );
    test(
      'force replaces an existing photo and keeps the identifier idempotent',
      () async {
        final first = await endpoint.attachSeedPhoto(s, secret, 'SEED01', jpeg);
        final second = await endpoint.attachSeedPhoto(
          s,
          secret,
          'SEED01',
          jpeg,
          force: true,
        );
        expect(second.id, first.id);
        expect(await WorkItem.db.count(s), 1);
        expect(await AuditEvent.db.count(s), 2);
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
