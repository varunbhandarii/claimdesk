@Tags(['integration'])
library;

import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Staff return records', (builder, endpoints) {
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    late Session s;
    late Venue venue;
    late FoundItem item;
    late LostReport report;
    late ItemMatch match;
    ReleaseInput input({bool linked = true}) => ReleaseInput(
      matchId: linked ? match.id : null,
      claimantName: 'Fictional Owner',
      idTypeSeen: 'passport',
      detailsMatched: 2,
      describedBeforeViewing: true,
      thirdParty: false,
    );
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s, slug: 'release-${const Uuid().v4()}');
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Demo Staff',
        ),
      );
      item = await makeItem(s, venue.id!);
      item = await FoundItem.db.updateRow(
        s,
        item.copyWith(status: ItemStatus.unclaimed),
      );
      report = await makeReport(s, venue.id!);
      report = await LostReport.db.updateRow(
        s,
        report.copyWith(status: ReportStatus.searching),
      );
      match = await makeMatch(s, item, report);
    });
    tearDown(() async {
      final releases = await ReleaseRecord.db.find(
        s,
        where: (t) => t.venueId.equals(venue.id!),
      );
      for (final r in releases) {
        if (r.signaturePath != null) {
          await s.storage.deleteFile(
            storageId: 'private',
            path: r.signaturePath!,
          );
        }
      }
      await AuditEvent.db.deleteWhere(
        s,
        where: (t) => t.venueId.equals(venue.id!),
      );
      await Venue.db.deleteRow(s, venue);
    });
    test('All return methods require venue membership', () async {
      final outsider = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          const Uuid().v4(),
          {},
        ),
      );
      for (final caller in [builder, outsider]) {
        for (final action in [
          () => endpoints.release.markReady(caller, match.id!),
          () => endpoints.release.release(caller, item.id!, input(), null),
          () => endpoints.release.releaseRecord(caller, item.id!),
          () => endpoints.release.signatureUrl(caller, item.id!),
        ]) {
          await expectLater(
            action(),
            throwsA(
              caller == builder
                  ? isA<ServerpodUnauthenticatedException>()
                  : isA<NotAMemberException>(),
            ),
          );
        }
      }
    });
    test(
      'Confirmed return closes both parents, preserves reservation and produces a private signed receipt',
      () async {
        await endpoints.match.confirm(member, match.id!);
        final ready = await endpoints.release.markReady(member, match.id!);
        expect(ready.report.status, ReportStatus.readyForPickup);
        await expectLater(
          endpoints.release.markReady(member, match.id!),
          throwsA(isA<MatchStateException>()),
        );
        final otherReport = await makeReport(
          s,
          venue.id!,
          refCode: 'OTHER1',
          publicToken: 'other',
        );
        final otherItem = await makeItem(s, venue.id!, refCode: 'OTHER2');
        final competitors = [
          await makeMatch(s, item, otherReport),
          await makeMatch(s, otherItem, report),
        ];
        final signature = ByteData.sublistView(
          Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0]),
        );
        final summary = await endpoints.release.release(
          member,
          item.id!,
          input(),
          signature,
        );
        expect(summary.record.venueId, item.venueId);
        expect(summary.releasedByName, 'Demo Staff');
        expect(summary.reportRefCode, report.refCode);
        expect(
          await s.storage.fileExists(
            storageId: 'private',
            path: summary.record.signaturePath!,
          ),
          isTrue,
        );
        expect(
          await endpoints.release.signatureUrl(member, item.id!),
          isNotNull,
        );
        expect(
          (await FoundItem.db.findById(s, item.id!))!.status,
          ItemStatus.claimed,
        );
        final returned = await LostReport.db.findById(s, report.id!);
        expect(returned!.status, ReportStatus.returned);
        expect(returned.closedAt, isNotNull);
        expect(
          (await ItemMatch.db.findById(s, match.id!))!.state,
          MatchState.confirmed,
        );
        for (final row in competitors) {
          expect(
            (await ItemMatch.db.findById(s, row.id!))!.state,
            MatchState.superseded,
          );
        }
        final audits = await AuditEvent.db.find(
          s,
          where: (t) =>
              t.venueId.equals(venue.id!) &
              t.action.inSet({'released', 'returned'}),
        );
        expect(audits, hasLength(2));
        expect(audits.toString(), isNot(contains('Fictional Owner')));
        await expectLater(
          endpoints.match.reject(member, match.id!, 'Undo after return'),
          throwsA(isA<MatchStateException>()),
        );
        await expectLater(
          endpoints.release.release(member, item.id!, input(), null),
          throwsA(isA<AlreadyReleasedException>()),
        );
      },
    );
    test(
      'Walk-in release works and a reservation refuses walk-ins without leaving a signature',
      () async {
        await endpoints.match.confirm(member, match.id!);
        final png = ByteData.sublistView(
          Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
        );
        await expectLater(
          endpoints.release.release(
            member,
            item.id!,
            input(linked: false),
            png,
          ),
          throwsA(
            isA<ReleaseRefusedException>().having(
              (e) => e.message,
              'reason',
              contains(report.refCode),
            ),
          ),
        );
        expect(
          await ReleaseRecord.db.count(
            s,
            where: (t) => t.itemId.equals(item.id!),
          ),
          0,
        );
        expect(
          (await s.db.unsafeQuery(
            'SELECT count(*) FROM serverpod_cloud_storage WHERE path LIKE @prefix',
            parameters: QueryParameters.named({
              'prefix': 'venues/${venue.id}/releases/${item.id}/%',
            }),
          )).single.single,
          0,
        );
        await endpoints.match.reject(member, match.id!, 'Owner withdrew');
        final released = await endpoints.release.release(
          member,
          item.id!,
          input(linked: false),
          null,
        );
        expect(released.record.reportId, isNull);
        expect(released.record.signaturePath, isNull);
      },
    );
    test('Off-shelf items and mismatched reservations are refused', () async {
      for (final state in [
        ItemStatus.claimed,
        ItemStatus.transferred,
        ItemStatus.disposed,
        ItemStatus.expired,
      ]) {
        await FoundItem.db.updateRow(s, item.copyWith(status: state));
        await expectLater(
          endpoints.release.release(
            member,
            item.id!,
            input(linked: false),
            null,
          ),
          throwsA(isA<ReleaseRefusedException>()),
        );
      }
      await FoundItem.db.updateRow(
        s,
        item.copyWith(status: ItemStatus.unclaimed),
      );
      await expectLater(
        endpoints.release.markReady(member, match.id!),
        throwsA(isA<MatchStateException>()),
      );
      await expectLater(
        endpoints.release.release(member, item.id!, input(), null),
        throwsA(isA<MatchStateException>()),
      );
    });
    test(
      'Concurrent releases create exactly one permanent return record',
      () async {
        final results = await Future.wait([
          for (var n = 0; n < 2; n++)
            endpoints.release
                .release(
                  member,
                  item.id!,
                  input(linked: false),
                  ByteData.sublistView(
                    Uint8List.fromList([
                      137,
                      80,
                      78,
                      71,
                      13,
                      10,
                      26,
                      10,
                      n,
                    ]),
                  ),
                )
                .then<Object>((r) => r)
                .catchError((Object e) => e),
        ]);
        expect(results.whereType<ReleaseSummary>(), hasLength(1));
        expect(results.whereType<AlreadyReleasedException>(), hasLength(1));
        final winner = results.whereType<ReleaseSummary>().single;
        expect(
          await s.storage.fileExists(
            storageId: 'private',
            path: winner.record.signaturePath!,
          ),
          isTrue,
        );
        expect(
          (await s.db.unsafeQuery(
            'SELECT count(*) FROM serverpod_cloud_storage WHERE path LIKE @prefix',
            parameters: QueryParameters.named({
              'prefix': 'venues/${venue.id}/releases/${item.id}/%',
            }),
          )).single.single,
          1,
        );
        expect(
          await ReleaseRecord.db.count(
            s,
            where: (t) => t.itemId.equals(item.id!),
          ),
          1,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
