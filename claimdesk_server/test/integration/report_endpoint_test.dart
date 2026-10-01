import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Staff reports', (builder, endpoints) {
    final member = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        actorId.uuid,
        {},
      ),
    );
    late Venue venue;
    late LostReport report;
    setUp(() async {
      final s = builder.build();
      venue = await makeVenue(s);
      await StaffMembership.db.insertRow(
        s,
        StaffMembership(
          venueId: venue.id!,
          authUserId: actorId,
          displayName: 'Staff',
        ),
      );
      report = await makeReport(
        s,
        venue.id!,
        refCode: 'ABC234',
        publicToken: 'owner-only-secret-token',
      );
    });
    test(
      'members list, open and find reports without owner credentials',
      () async {
        expect(
          await endpoints.report.listReports(member, venue.id!, ReportFilter()),
          hasLength(1),
        );
        final view = await endpoints.report.getReport(member, report.id!);
        expect(view.publicToken, isEmpty);
        expect(
          (await endpoints.report.findByRefCode(
            member,
            venue.id!,
            ' abc234 ',
          ))?.id,
          report.id,
        );
        expect(
          await endpoints.report.findByRefCode(member, venue.id!, 'ZZZZZZ'),
          isNull,
        );
        expect(
          (await LostReport.db.findById(
            builder.build(),
            report.id!,
          ))!.publicToken,
          report.publicToken,
        );
      },
    );
    test('other venues and anonymous callers are refused', () async {
      final other = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          const Uuid().v4(),
          {},
        ),
      );
      await expectLater(
        endpoints.report.listReports(other, venue.id!, ReportFilter()),
        throwsA(isA<NotAMemberException>()),
      );
      await expectLater(
        endpoints.report.getReport(other, report.id!),
        throwsA(isA<NotAMemberException>()),
      );
      await expectLater(
        endpoints.report.findByRefCode(other, venue.id!, 'ABC234'),
        throwsA(isA<NotAMemberException>()),
      );
      await expectLater(
        endpoints.report.closeReport(other, report.id!, 'Not mine'),
        throwsA(isA<NotAMemberException>()),
      );
      await expectLater(
        endpoints.report.getReport(builder, report.id!),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
    test(
      'filters stay in the venue and cap the newest reports at 100',
      () async {
        final s = builder.build();
        final zone = await Zone.db.insertRow(
          s,
          Zone(venueId: venue.id!, name: 'Lobby', adjacentZoneIds: []),
        );
        final now = DateTime.now().toUtc();
        await LostReport.db.insert(
          s,
          List.generate(
            102,
            (i) => LostReport(
              venueId: venue.id!,
              refCode: 'R${i.toString().padLeft(5, '0')}',
              publicToken: 'filter-token-$i',
              rawText: 'A blue canvas shoulder bag',
              colourHints: ['blue'],
              categoryHint: 'backpack',
              zoneId: zone.id!,
              status: ReportStatus.searching,
              createdAt: now.add(Duration(seconds: i)),
            ),
          ),
        );
        final other = await makeVenue(s, slug: 'other-desk');
        await makeReport(
          s,
          other.id!,
          refCode: 'OTHER1',
          publicToken: 'other-ticket',
        );
        final rows = await endpoints.report.listReports(
          member,
          venue.id!,
          ReportFilter(),
        );
        expect(rows, hasLength(100));
        expect(rows.first.refCode, 'R00101');
        expect(rows.every((r) => r.venueId == venue.id), isTrue);
        expect(
          await endpoints.report.listReports(
            member,
            venue.id!,
            ReportFilter(
              status: ReportStatus.searching,
              zoneId: zone.id!,
              category: 'backpack',
            ),
          ),
          hasLength(100),
        );
        expect(
          await endpoints.report.listReports(
            member,
            venue.id!,
            ReportFilter(
              category: 'umbrella',
            ),
          ),
          isEmpty,
        );
      },
    );
    test(
      'close changes state, audits and excludes the report from open lists',
      () async {
        final s = builder.build();
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        try {
          final closed = await endpoints.report.closeReport(
            member,
            report.id!,
            'Owner found their item',
          );
          await flushEventQueue();
          expect(closed.status, ReportStatus.closed);
          expect(closed.closedAt, isNotNull);
          expect(events.single.kind, 'reportStatus');
          final audit = await AuditEvent.db.findFirstRow(
            s,
            where: (t) => t.entityId.equals(report.id!),
          );
          expect(audit!.action, 'closed');
          expect(audit.payload!.data['refCode'], 'ABC234');
          expect(
            await endpoints.report.listReports(
              member,
              venue.id!,
              ReportFilter(),
            ),
            isEmpty,
          );
          expect(
            await endpoints.report.listReports(
              member,
              venue.id!,
              ReportFilter(status: ReportStatus.closed),
            ),
            hasLength(1),
          );
          await expectLater(
            endpoints.report.closeReport(member, report.id!, 'Again'),
            throwsArgumentError,
          );
        } finally {
          await sub.cancel();
        }
      },
    );
    test('close refuses blank reason and protected states', () async {
      await expectLater(
        endpoints.report.closeReport(member, report.id!, '  '),
        throwsArgumentError,
      );
      await LostReport.db.updateRow(
        builder.build(),
        report.copyWith(status: ReportStatus.readyForPickup),
      );
      await expectLater(
        endpoints.report.closeReport(member, report.id!, 'Reason'),
        throwsArgumentError,
      );
    });
  });
}
