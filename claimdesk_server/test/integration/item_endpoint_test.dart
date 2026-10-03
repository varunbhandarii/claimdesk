import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/ai/providers.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/handlers/caption_item_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/reembed_item_handler.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

void main() {
  withServerpod('Given found-item intake', (builder, endpoints) {
    setUp(() => clearWorkerTestData(builder.build()));
    tearDown(() => clearWorkerTestData(builder.build()));
    late Session s;
    late Venue venue;
    late Zone zone;
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final stranger = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      zone = await Zone.db.insertRow(
        s,
        Zone(venueId: venue.id!, name: 'Desk', adjacentZoneIds: []),
      );
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Staff',
        ),
      );
      Providers.captioner = FakeCaptioner();
      Providers.embedder = FakeEmbedder();
    });
    Future<FoundItem> create() => endpoints.item.createItem(
      member,
      venue.id!,
      CreateItemInput(category: 'umbrella', zoneId: zone.id),
    );
    Future<void> tick() => JobWorker(
      s.serverpod,
      handlers: [CaptionItemHandler(), ReembedItemHandler()],
      renewLeases: false,
    ).tick(s);
    test(
      'a member receives an expiring upload ticket scoped to their venue',
      () async {
        final ticket = await endpoints.item.requestPhotoUpload(
          member,
          venue.id!,
          'image/jpeg',
        );
        expect(ticket.path, 'venues/${venue.id}/items/${ticket.itemId}.jpg');
        expect(ticket.proof, isNotEmpty);
        expect(ticket.expiresAt.isAfter(DateTime.now().toUtc()), true);
        expect(ticket.uploadDescription, isNotEmpty);
      },
    );
    test(
      'an item without a photo queues durable work in its creation transaction',
      () async {
        final item = await create();
        expect(item.status, ItemStatus.captioning);
        expect(item.refCode, hasLength(6));
        expect(item.loggedByAuthUserId, actorId);
        expect((await WorkItem.db.find(s)).single.venueId, item.venueId);
        expect((await AuditEvent.db.find(s)).single.action, 'created');
        await tick();
        expect(
          (await endpoints.item.getItem(member, item.id!)).status,
          ItemStatus.unclaimed,
        );
      },
    );
    test(
      'unverified uploads and fabricated or expired paths are refused',
      () async {
        final t = await endpoints.item.requestPhotoUpload(
          member,
          venue.id!,
          'image/jpeg',
        );
        final input = CreateItemInput(
          itemId: t.itemId,
          photoPath: t.path,
          uploadProof: t.proof,
          uploadExpiresAt: t.expiresAt,
        );
        for (final invalid in [
          input,
          input.copyWith(photoPath: 'venues/other/photo.jpg'),
          input.copyWith(uploadProof: 'tampered'),
          input.copyWith(
            uploadExpiresAt: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
          ),
        ]) {
          await expectLater(
            endpoints.item.createItem(member, venue.id!, invalid),
            throwsArgumentError,
          );
        }
        expect(await FoundItem.db.count(s), 0);
        expect(await WorkItem.db.count(s), 0);
      },
    );
    test('all intake reads and writes reject nonmembers', () async {
      final item = await create();
      for (final call in <Future<dynamic> Function()>[
        () => endpoints.item.requestPhotoUpload(
          stranger,
          venue.id!,
          'image/jpeg',
        ),
        () => endpoints.item.createItem(stranger, venue.id!, CreateItemInput()),
        () => endpoints.item.getItem(stranger, item.id!),
        () => endpoints.item.listItems(stranger, venue.id!, ItemFilter()),
        () => endpoints.item.photoUrl(stranger, item.id!, thumb: false),
        () => endpoints.item.updateItem(stranger, item.id!, ItemPatch()),
        () => endpoints.item.recaption(stranger, item.id!),
        () => endpoints.item.captionRuns(stranger, item.id!),
      ]) {
        await expectLater(call(), throwsA(isA<NotAMemberException>()));
      }
    });
    test(
      'foreign zones are refused and list filters by status zone and category',
      () async {
        final item = await create();
        final other = await makeVenue(s, slug: 'other');
        final foreign = await Zone.db.insertRow(
          s,
          Zone(venueId: other.id!, name: 'Other', adjacentZoneIds: []),
        );
        await expectLater(
          endpoints.item.createItem(
            member,
            venue.id!,
            CreateItemInput(zoneId: foreign.id),
          ),
          throwsArgumentError,
        );
        await expectLater(
          endpoints.item.updateItem(
            member,
            item.id!,
            ItemPatch(zoneId: foreign.id),
          ),
          throwsArgumentError,
        );
        await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.disposed),
        );
        expect(
          await endpoints.item.listItems(member, venue.id!, ItemFilter()),
          isEmpty,
        );
        expect(
          await endpoints.item.listItems(
            member,
            venue.id!,
            ItemFilter(
              status: ItemStatus.disposed,
              zoneId: zone.id,
              category: 'umbrella',
            ),
          ),
          hasLength(1),
        );
        expect(
          await endpoints.item.listItems(
            member,
            venue.id!,
            ItemFilter(status: ItemStatus.disposed, category: 'backpack'),
          ),
          isEmpty,
        );
      },
    );
    test(
      'recaption reuses the same job and prompt after an earlier success',
      () async {
        final item = await create();
        await tick();
        final first = (await WorkItem.db.find(
          s,
          where: (t) => t.kind.equals('caption_item'),
        )).single;
        final next = await endpoints.item.recaption(member, item.id!);
        expect(next.id, first.id);
        expect(next.state, WorkState.pending);
        expect(
          await WorkItem.db.count(
            s,
            where: (t) => t.kind.equals('caption_item'),
          ),
          1,
        );
        await tick();
        expect(await CaptionRun.db.count(s), 2);
        expect(
          (await endpoints.item.getItem(member, item.id!)).status,
          ItemStatus.unclaimed,
        );
      },
    );
    test(
      'staff edits re-embed asynchronously and apply privacy and retention rules',
      () async {
        final item = await create();
        await tick();
        final original = await endpoints.item.getItem(member, item.id!);
        final edited = await endpoints.item.updateItem(
          member,
          item.id!,
          ItemPatch(
            attributes: original.attributes!.copyWith(
              category: 'id_card_or_pass',
              description: 'Fictional Person 123456',
              brand: 'Secret 987',
              marks: ['Name 234'],
            ),
            storageBin: 'Bin 3',
            privateNotes: 'Staff only',
            valueBand: ValueBand.from100to499,
          ),
        );
        expect(edited.restricted, true);
        expect(edited.captionText, isNot(contains('123456')));
        expect(edited.attributes!.brand, isNull);
        expect(edited.embedding, isNull);
        expect(edited.holdUntil, edited.foundAt.add(const Duration(days: 30)));
        expect(edited.handoffDueAt, isNotNull);
        final job = await WorkItem.db.findFirstRow(
          s,
          where: (t) => t.kind.equals('reembed_item'),
        );
        expect(job!.venueId, item.venueId);
        await tick();
        expect(
          (await endpoints.item.getItem(member, item.id!)).embedding,
          isNull,
        );
        expect(
          (await FoundItem.db.findById(s, item.id!))!.embedding,
          isNotNull,
        );
        final cleared = await endpoints.item.updateItem(
          member,
          item.id!,
          ItemPatch(
            clearStorageBin: true,
            clearPrivateNotes: true,
            clearZone: true,
          ),
        );
        expect(cleared.storageBin, isNull);
        expect(cleared.privateNotes, isNull);
        expect(cleared.zoneId, isNull);
      },
    );
    test('missing originals and thumbnails have no photo URL', () async {
      final item = await create();
      expect(
        await endpoints.item.photoUrl(member, item.id!, thumb: false),
        isNull,
      );
      expect(
        await endpoints.item.photoUrl(member, item.id!, thumb: true),
        isNull,
      );
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
