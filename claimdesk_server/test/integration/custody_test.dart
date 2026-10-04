import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/policy/custody.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Custody at the desk', (builder, endpoints) {
    late Session s;
    late Venue venue;
    late FoundItem item;
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
      venue = await makeVenue(s, slug: 'custody-${const Uuid().v4()}');
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Desk staff',
        ),
      );
      item = await makeItem(s, venue.id!, embedding: unitVector(1, 0));
      item = await FoundItem.db.updateRow(
        s,
        item.copyWith(status: ItemStatus.unclaimed),
      );
    });
    tearDown(() async {
      await AuditEvent.db.deleteWhere(
        s,
        where: (t) => t.venueId.equals(venue.id),
      );
      await Venue.db.deleteRow(s, venue);
      await s.close();
    });
    test(
      'moves preserve shelf state and terminal transfer rejects only pending matches',
      () async {
        final delivered = <DeskEvent>[];
        final subscription = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(delivered.add);
        addTearDown(subscription.cancel);
        await flushEventQueue();
        final report = await makeReport(s, venue.id!);
        final pending = await makeMatch(s, item, report);
        expect(
          Custody.current(await endpoints.item.custody(member, item.id!)),
          'desk',
        );
        final moved = await endpoints.item.transfer(
          member,
          item.id!,
          TransferInput(
            toLocation: 'safe',
            reference: ' SAFE\n12 ',
            note: 'Private operational note',
          ),
        );
        expect(moved.status, ItemStatus.unclaimed);
        expect(moved.embedding, isNull);
        await endpoints.item.transfer(
          member,
          item.id!,
          TransferInput(toLocation: 'desk'),
        );
        final transferred = await endpoints.item.transfer(
          member,
          item.id!,
          TransferInput(toLocation: 'police', reference: 'POL-24'),
        );
        expect(transferred.status, ItemStatus.transferred);
        await flushEventQueue();
        expect(delivered, hasLength(3));
        expect(
          delivered.every((e) => e.kind == 'itemStatus' && e.itemId == item.id),
          true,
        );
        final events = await endpoints.item.custody(member, item.id!);
        expect(events, hasLength(3));
        expect(Custody.current(events.reversed), 'police');
        expect(
          events.every(
            (e) => e.venueId == item.venueId && e.byAuthUserId == actorId,
          ),
          true,
        );
        expect(events.last.reference, 'SAFE 12');
        expect(events.first.fromLocation, 'desk');
        expect(
          (await ItemMatch.db.findById(s, pending.id!))!.state,
          MatchState.rejected,
        );
        expect(
          (await LostReport.db.findById(s, report.id!))!.status,
          report.status,
        );
        final audit = await AuditEvent.db.find(
          s,
          where: (t) => t.entityId.equals(item.id!),
        );
        expect(audit, hasLength(3));
        expect(audit.every((a) => a.actorAuthUserId == actorId), true);
        final history = await endpoints.item.history(member, item.id!);
        expect(history.where((e) => e.kind == 'custody'), hasLength(3));
        stdout.writeln(
          history.map((e) => '${e.kind}: ${e.summary} · ${e.actor}').join('\n'),
        );
      },
    );
    test(
      'issuer accepts each shelf status, terminal statuses and intake refuse',
      () async {
        for (final status in [
          ItemStatus.unclaimed,
          ItemStatus.matched,
          ItemStatus.expired,
        ]) {
          item = await FoundItem.db.updateRow(s, item.copyWith(status: status));
          expect(
            (await endpoints.item.transfer(
              member,
              item.id!,
              TransferInput(toLocation: 'issuer'),
            )).status,
            ItemStatus.transferred,
          );
        }
        for (final status in [
          ItemStatus.intake,
          ItemStatus.captioning,
          ItemStatus.claimed,
          ItemStatus.transferred,
          ItemStatus.disposed,
        ]) {
          item = await FoundItem.db.updateRow(s, item.copyWith(status: status));
          await expectLater(
            endpoints.item.transfer(
              member,
              item.id!,
              TransferInput(toLocation: 'safe'),
            ),
            throwsA(isA<ReleaseRefusedException>()),
          );
        }
      },
    );
    test(
      'a reservation allows a safe move and blocks leaving without any partial write',
      () async {
        final report = await makeReport(s, venue.id!, refCode: 'K7P2QM');
        final match = await makeMatch(s, item, report);
        await ItemMatch.db.updateRow(
          s,
          match.copyWith(state: MatchState.confirmed),
        );
        item = await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.matched),
        );
        await endpoints.item.transfer(
          member,
          item.id!,
          TransferInput(toLocation: 'safe'),
        );
        for (final location in ['police', 'issuer']) {
          await expectLater(
            endpoints.item.transfer(
              member,
              item.id!,
              TransferInput(toLocation: location),
            ),
            throwsA(
              isA<ReleaseRefusedException>().having(
                (e) => e.message,
                'reservation',
                contains('K7P2QM'),
              ),
            ),
          );
        }
        expect(
          await CustodyEvent.db.count(
            s,
            where: (t) => t.itemId.equals(item.id),
          ),
          1,
        );
        expect(
          (await ItemMatch.db.findById(s, match.id!))!.state,
          MatchState.confirmed,
        );
      },
    );
    test(
      'disposal is expired-only, audited, and excludes personal notes from history',
      () async {
        for (final status in ItemStatus.values.where(
          (s) => s != ItemStatus.expired,
        )) {
          item = await FoundItem.db.updateRow(s, item.copyWith(status: status));
          await expectLater(
            endpoints.item.dispose(
              member,
              item.id!,
              DisposeInput(action: 'donate'),
            ),
            throwsA(isA<ReleaseRefusedException>()),
          );
        }
        item = await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.expired),
        );
        final disposed = await endpoints.item.dispose(
          member,
          item.id!,
          DisposeInput(action: 'recycle', note: 'PRIVATE NOTE'),
        );
        expect(disposed.status, ItemStatus.disposed);
        final history = await endpoints.item.history(member, item.id!);
        expect(history.single.action, 'disposed');
        expect(history.single.data, {'action': 'recycle'});
        stdout.writeln(
          '${history.single.summary} · ${history.single.actor} · recycle',
        );
      },
    );
    test(
      'location, length and membership validation precedes writes',
      () async {
        await expectLater(
          endpoints.item.transfer(
            member,
            item.id!,
            TransferInput(toLocation: 'somewhere'),
          ),
          throwsArgumentError,
        );
        await expectLater(
          endpoints.item.transfer(
            member,
            item.id!,
            TransferInput(toLocation: 'safe', reference: 'x' * 121),
          ),
          throwsArgumentError,
        );
        await expectLater(
          endpoints.item.dispose(
            member,
            item.id!,
            DisposeInput(action: 'other'),
          ),
          throwsArgumentError,
        );
        await expectLater(
          endpoints.item.transfer(
            stranger,
            item.id!,
            TransferInput(toLocation: 'safe'),
          ),
          throwsA(isA<NotAMemberException>()),
        );
        await expectLater(
          endpoints.item.dispose(
            stranger,
            item.id!,
            DisposeInput(action: 'discard'),
          ),
          throwsA(isA<NotAMemberException>()),
        );
        await expectLater(
          endpoints.item.custody(stranger, item.id!),
          throwsA(isA<NotAMemberException>()),
        );
        expect(
          await CustodyEvent.db.count(
            s,
            where: (t) => t.itemId.equals(item.id),
          ),
          0,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
