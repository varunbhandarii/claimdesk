import 'dart:convert';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:claimdesk_server/src/services/venue_exports.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show CloudStorageEntry;
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Supervisor CSV export', (builder, endpoints) {
    late Session s;
    late Venue venue;
    late FoundItem item;
    late LostReport report;
    final supervisor = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    final staffId = UuidValue.fromString(const Uuid().v4());
    final staff = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        staffId.uuid,
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
          displayName: 'Supervisor',
          role: StaffRole.supervisor,
        ),
      );
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: staffId,
          displayName: 'Desk staff',
        ),
      );
      item = await makeItem(s, venue.id!, embedding: unitVector(1, 0));
      item = await FoundItem.db.updateRow(
        s,
        item.copyWith(
          status: ItemStatus.claimed,
          privateNotes: 'FORBIDDEN-NOTES',
          finderName: 'FORBIDDEN-FINDER',
          attributes: ItemAttributes(
            category: 'umbrella',
            colours: ['black'],
            marks: ['FORBIDDEN-MARK'],
            description: 'A black umbrella',
            personalDataKinds: [],
            keywords: [],
            source: 'staff_typed',
          ),
        ),
      );
      report = await makeReport(s, venue.id!, publicToken: 'FORBIDDEN-TOKEN');
      report = await LostReport.db.updateRow(
        s,
        report.copyWith(
          ipHash: 'FORBIDDEN-HASH',
          ownerOnlyDetails: 'FORBIDDEN-OWNER-DETAIL',
          contactEmail: 'owner@example.test',
          ownerName: 'Fictional owner',
        ),
      );
      final match = await makeMatch(s, item, report);
      await ChildRecords.answer(
        s,
        matchId: match.id!,
        question: 'Proof?',
        answer: 'FORBIDDEN-ANSWER',
      );
      await ChildRecords.release(
        s,
        itemId: item.id!,
        reportId: report.id!,
        claimantName: 'Fictional claimant',
        idTypeSeen: 'Passport',
        detailsMatched: 2,
        describedBeforeViewing: true,
        releasedByAuthUserId: actorId,
        signaturePath: 'FORBIDDEN-SIGNATURE',
      );
      await ChildRecords.custody(
        s,
        itemId: item.id!,
        fromLocation: 'desk',
        toLocation: 'safe',
        byAuthUserId: actorId,
        reference: 'SAFE-9',
      );
    });
    test(
      'all five private CSVs have fixed headers, one row, expiry and one actor audit',
      () async {
        for (final kind in VenueExports.headers.keys) {
          final result = await endpoints.export.export(
            supervisor,
            venue.id!,
            kind,
          );
          expect(result.rows, 1);
          expect(result.kind, kind);
          expect(
            result.expiresAt.difference(DateTime.now().toUtc()).inSeconds,
            inInclusiveRange(595, 600),
          );
          final files = await CloudStorageEntry.db.find(
            s,
            where: (t) => t.storageId.equals('private'),
          );
          final file = files.singleWhere(
            (f) => f.path.startsWith('venues/${venue.id}/exports/$kind-'),
          );
          expect(file.contentType, 'text/csv; charset=utf-8');
          expect(file.cacheControl, 'no-store');
          expect(
            file.byteData.buffer.asUint8List(file.byteData.offsetInBytes, 3),
            [0xef, 0xbb, 0xbf],
          );
          final csv = utf8.decode(
            file.byteData.buffer.asUint8List(
              file.byteData.offsetInBytes,
              file.byteData.lengthInBytes,
            ),
          );
          expect(
            csv,
            startsWith('${VenueExports.headers[kind]!.join(',')}\r\n'),
          );
          expect(csv, isNot(contains('FORBIDDEN')));
          for (final field in [
            'publicToken',
            'ipHash',
            'embedding',
            'signaturePath',
            'ownerOnlyDetails',
          ]) {
            expect(csv, isNot(contains(field)));
          }
          if (kind == 'items') {
            expect(csv, contains('A black umbrella'));
            expect(csv, contains('Supervisor,safe'));
          }
          if (kind == 'reports') {
            expect(csv, contains('owner@example.test,Fictional owner'));
          }
          if (kind == 'matches') {
            expect(csv, contains('${report.refCode},${item.refCode},pending'));
          }
          if (kind == 'releases') {
            expect(csv, contains('Fictional claimant,Passport,2,true'));
          }
          if (kind == 'custody') {
            expect(
              csv,
              contains('${item.refCode},desk,safe,SAFE-9,Supervisor'),
            );
          }
          expect(result.url, isNotEmpty);
        }
        final audits = await AuditEvent.db.find(
          s,
          where: (t) =>
              t.entityId.equals(venue.id!) & t.action.equals('exported'),
        );
        expect(audits, hasLength(5));
        expect(
          audits.every(
            (a) =>
                a.actorAuthUserId == actorId && a.payload!.data['rows'] == '1',
          ),
          true,
        );
      },
    );
    test(
      'staff cannot export any kind and unknown kinds write nothing',
      () async {
        for (final kind in VenueExports.headers.keys) {
          await expectLater(
            endpoints.export.export(staff, venue.id!, kind),
            throwsA(
              isA<NotAMemberException>().having(
                (e) => e.message,
                'role',
                'Supervisor role required',
              ),
            ),
          );
        }
        await expectLater(
          endpoints.export.export(supervisor, venue.id!, 'answers'),
          throwsArgumentError,
        );
        expect(
          await CloudStorageEntry.db.count(
            s,
            where: (t) => t.storageId.equals('private'),
          ),
          0,
        );
      },
    );
    test('paging crosses 100 rows and never crosses the venue', () async {
      for (var n = 0; n < 101; n++) {
        await makeItem(
          s,
          venue.id!,
          refCode: 'CSV${n.toString().padLeft(3, '0')}',
        );
      }
      final other = await makeVenue(s, slug: 'other-export');
      await makeItem(s, other.id!, refCode: 'OTHER1');
      final data = await VenueExports.build(s, venue.id!, 'items');
      expect(data.rows, hasLength(102));
      expect(data.rows.any((r) => r.first == 'OTHER1'), false);
    });
  });
}
