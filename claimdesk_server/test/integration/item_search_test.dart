import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Staff shelf search', (builder, endpoints) {
    late Session s;
    late Venue venue;
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
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Desk staff',
        ),
      );
    });
    Future<FoundItem> add(
      String ref,
      String caption, {
      String category = 'umbrella',
      String? note,
      String? bin,
      ItemStatus status = ItemStatus.unclaimed,
      DateTime? found,
      UuidValue? zone,
    }) async {
      final item = await makeItem(
        s,
        venue.id!,
        refCode: ref,
        embedding: unitVector(1, 0),
        zoneId: zone,
      );
      return FoundItem.db.updateRow(
        s,
        item.copyWith(
          status: status,
          captionText: caption,
          privateNotes: note,
          storageBin: bin,
          foundAt: found,
          attributes: ItemAttributes(
            category: category,
            colours: [],
            marks: [],
            description: caption,
            personalDataKinds: [],
            keywords: [],
            source: 'staff_typed',
          ),
        ),
      );
    }

    Future<List<FoundItem>> search(String text, [ItemFilter? filter]) =>
        endpoints.item.searchItems(
          member,
          venue.id!,
          text,
          filter ?? ItemFilter(),
        );
    test(
      'caption, synonym, notes and bins rank by coverage and date without leaking vectors',
      () async {
        final old = await add(
          'OLD001',
          'A red umbrella',
          found: DateTime.utc(2026, 1, 1),
        );
        final newest = await add(
          'NEW001',
          'A red umbrella',
          found: DateTime.utc(2026, 1, 2),
        );
        await add('PART01', 'A blue umbrella', found: DateTime.utc(2026, 1, 3));
        final notes = await add(
          'NOTE01',
          'A bag',
          category: 'backpack',
          note: 'hidden violet ribbon',
          bin: 'CUPBOARD-9',
        );
        expect((await search('red umbrella')).map((i) => i.refCode), [
          'NEW001',
          'OLD001',
          'PART01',
        ]);
        expect((await search('brolly')).map((i) => i.refCode), [
          'PART01',
          'NEW001',
          'OLD001',
        ]);
        expect((await search('violet')).single.id, notes.id);
        expect((await search('CUPBOARD-9')).single.id, notes.id);
        expect((await search('old001')).single.id, old.id);
        expect((await search('red')).every((i) => i.embedding == null), true);
        expect((await search('red', ItemFilter(category: 'Bags'))), isEmpty);
        expect(
          (await search('ribbon', ItemFilter(category: 'Bags'))).single.id,
          notes.id,
        );
        final other = await makeVenue(s, slug: 'other-search');
        await makeItem(s, other.id!, refCode: newest.refCode);
        expect((await search('NEW001')).single.venueId, venue.id);
      },
    );
    test(
      'zone, status, category and attention intersect with references and words',
      () async {
        final zone = await Zone.db.insertRow(
          s,
          Zone(venueId: venue.id!, name: 'Pool', adjacentZoneIds: []),
        );
        final active = await add('ACT001', 'A blue umbrella', zone: zone.id);
        final disposed = await add(
          'GONE01',
          'A blue umbrella',
          status: ItemStatus.disposed,
        );
        final expired = await add(
          'EXPIRE',
          'A blue umbrella',
          status: ItemStatus.expired,
        );
        await FoundItem.db.updateRow(
          s,
          expired.copyWith(
            handoffDueAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        );
        expect((await search('umbrella')).map((i) => i.id), [active.id]);
        expect(
          (await search(
            'umbrella',
            ItemFilter(status: ItemStatus.disposed),
          )).single.id,
          disposed.id,
        );
        expect((await search('GONE01')), isEmpty);
        expect(
          (await search(
            'GONE01',
            ItemFilter(status: ItemStatus.disposed),
          )).single.id,
          disposed.id,
        );
        expect(
          (await search('umbrella', ItemFilter(zoneId: zone.id))).single.id,
          active.id,
        );
        expect(
          (await search('umbrella', ItemFilter(category: 'backpack'))),
          isEmpty,
        );
        expect(
          (await search(
            'umbrella',
            ItemFilter(attention: 'overdue'),
          )).single.id,
          expired.id,
        );
        expect(
          (await search('ACT001', ItemFilter(status: ItemStatus.expired))),
          isEmpty,
        );
      },
    );
    test(
      'length, empty fallback, caps and membership are enforced by the server',
      () async {
        for (var n = 0; n < 55; n++) {
          await add('CAP${n.toString().padLeft(3, '0')}', 'umbrella');
        }
        expect(await search('umbrella'), hasLength(50));
        expect(await search('  '), hasLength(55));
        await expectLater(search(' x '), throwsArgumentError);
        await expectLater(search('x' * 81), throwsArgumentError);
        await expectLater(
          search('umbrella', ItemFilter(attention: 'bad')),
          throwsArgumentError,
        );
        await expectLater(
          endpoints.item.searchItems(
            stranger,
            venue.id!,
            'umbrella',
            ItemFilter(),
          ),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
  });
}
