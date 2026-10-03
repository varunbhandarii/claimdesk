import 'dart:convert';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Venue record history', (builder, endpoints) {
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
          displayName: 'Alex at the desk',
        ),
      );
    });
    test(
      'four kinds merge newest first with actors and safe release details',
      () async {
        final item = await makeItem(s, venue.id!);
        var report = await makeReport(
          s,
          venue.id!,
          publicToken: 'DO-NOT-SHOW-TOKEN',
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(
            status: ReportStatus.returned,
            ipHash: 'DO-NOT-SHOW-HASH',
          ),
        );
        await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: venue.id!,
            entityType: 'item',
            entityId: item.id!,
            action: 'created',
            actorAuthUserId: actorId,
            at: DateTime.utc(2026, 1, 1),
            payload: AuditPayload(
              summary: 'DO-NOT-SHOW-NAME',
              data: {
                'ownerName': 'DO-NOT-SHOW-NAME',
                'answer': 'DO-NOT-SHOW-ANSWER',
              },
            ),
          ),
        );
        await ChildRecords.caption(
          s,
          itemId: item.id!,
          provider: 'claude',
          modelId: 'test-model',
          promptVersion: 'v1',
          outcome: 'success',
          latencyMs: 123,
          errorMessage: 'DO-NOT-SHOW-TOKEN',
        );
        await ChildRecords.custody(
          s,
          itemId: item.id!,
          fromLocation: 'desk',
          toLocation: 'safe',
          byAuthUserId: actorId,
          reference: 'SAFE-12',
        );
        final former = UuidValue.fromString(const Uuid().v4());
        final other = await makeVenue(s, slug: 'other-history');
        await StaffMembership.db.insertRow(
          s,
          StaffMembership(
            venueId: other.id!,
            authUserId: former,
            displayName: 'DO-NOT-SHOW-OTHER-VENUE',
          ),
        );
        await ChildRecords.release(
          s,
          itemId: item.id!,
          reportId: report.id!,
          claimantName: 'DO-NOT-SHOW-NAME',
          idTypeSeen: 'Passport',
          detailsMatched: 2,
          describedBeforeViewing: true,
          releasedByAuthUserId: former,
          signaturePath: 'DO-NOT-SHOW-SIGNATURE',
        );
        final entries = await endpoints.item.history(member, item.id!);
        expect(entries.map((e) => e.kind).toSet(), {
          'audit',
          'caption',
          'custody',
          'release',
        });
        expect(entries.first.kind, 'release');
        expect(entries.last.at, DateTime.utc(2026, 1, 1));
        expect(
          entries.singleWhere((e) => e.kind == 'audit').actor,
          'Alex at the desk',
        );
        expect(entries.singleWhere((e) => e.kind == 'caption').actor, 'System');
        expect(entries.first.actor, 'Former staff member');
        expect(entries.first.data, {
          'idTypeSeen': 'Passport',
          'detailsMatched': '2',
        });
        final reportHistory = await endpoints.report.history(
          member,
          report.id!,
        );
        expect(reportHistory.single.kind, 'release');
        for (final rows in [entries, reportHistory]) {
          expect(
            jsonEncode(rows.map((e) => e.toJson()).toList()),
            isNot(contains('DO-NOT-SHOW')),
          );
        }
      },
    );
    test(
      'owner and job actions have safe summaries and bounded newest history',
      () async {
        final report = await makeReport(s, venue.id!);
        for (var n = 0; n < 202; n++) {
          await AuditEvent.db.insertRow(
            s,
            AuditEvent(
              venueId: venue.id!,
              entityType: 'report',
              entityId: report.id!,
              action: n == 201 ? 'answered' : 'normalised',
              at: DateTime.utc(2026, 1, 1).add(Duration(seconds: n)),
              payload: AuditPayload(
                summary: 'Unsafe free text',
                data: {
                  'count': '2',
                  'provider': 'claude',
                  'latencyMs': '123',
                  'answer': 'SECRET',
                },
              ),
            ),
          );
        }
        final rows = await endpoints.report.history(member, report.id!);
        expect(rows, hasLength(200));
        expect(rows.first.actor, 'Owner');
        expect(rows.first.summary, 'Owner answered the questions');
        expect(rows[1].actor, 'System');
        expect(rows.first.data['count'], '2');
        expect(rows.first.data, isNot(contains('answer')));
        await expectLater(
          endpoints.report.history(stranger, report.id!),
          throwsA(isA<NotAMemberException>()),
        );
        final item = await makeItem(s, venue.id!);
        await expectLater(
          endpoints.item.history(stranger, item.id!),
          throwsA(isA<NotAMemberException>()),
        );
      },
    );
  });
}
