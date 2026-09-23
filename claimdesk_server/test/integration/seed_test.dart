import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/policy/retention.dart';
import 'package:claimdesk_server/src/services/seed_service.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an empty demo desk', (builder, endpoints) {
    setUp(configureTestAuth);

    test(
      'when seeding twice then all rows and auth identities remain stable',
      () async {
        final s = builder.build();
        final first = await SeedService.seedDemo(s);
        final before = (await Zone.db.find(
          s,
          orderBy: (t) => t.sortOrder,
        )).map((z) => z.toJson()).toList();
        final membershipsBefore = (await StaffMembership.db.find(
          s,
          orderBy: (t) => t.displayName,
        )).map((m) => m.toJson()).toList();
        final second = await SeedService.seedDemo(s);
        expect(second, first);
        expect(await Venue.db.count(s), 1);
        expect(await Zone.db.count(s), 6);
        expect(await StaffMembership.db.count(s), 2);
        expect(await AuthServices.instance.authUsers.list(s), hasLength(2));
        final venue = (await Venue.db.findById(s, first.venueId))!;
        expect(venue.name, 'Hawrys Rec Center (demo)');
        expect(
          venue.retentionPolicy!.toJson(),
          defaultRetentionPolicy().toJson(),
        );
        final zones = await Zone.db.find(s, orderBy: (t) => t.sortOrder);
        expect(zones.map((z) => z.toJson()).toList(), before);
        expect(zones.map((z) => z.name), SeedService.zoneNames);
        expect(zones[0].adjacentZoneIds, [zones[1].id, zones[3].id]);
        expect(zones[2].adjacentZoneIds, [zones[3].id]);
        expect(
          (await StaffMembership.db.find(
            s,
            orderBy: (t) => t.displayName,
          )).map((m) => m.toJson()).toList(),
          membershipsBefore,
        );
        final admin = AuthServices.instance.emailIdp.admin;
        expect(
          (await admin.findAccount(
            s,
            email: SeedService.supervisorEmail,
          ))!.authUserId,
          first.supervisorId,
        );
        expect(
          (await admin.findAccount(
            s,
            email: SeedService.staffEmail,
          ))!.authUserId,
          first.staffId,
        );
        expect(first.supervisorId, isNot(first.staffId));
        expect(
          (await AuthServices.instance.authUsers.get(
            s,
            authUserId: first.staffId,
          )).id,
          first.staffId,
        );
      },
    );

    test(
      'when mutable demo rows drift then seeding repairs them without replacing ids',
      () async {
        final s = builder.build();
        final first = await SeedService.seedDemo(s);
        final venue = (await Venue.db.findById(s, first.venueId))!;
        await Venue.db.updateRow(s, venue.copyWith(name: 'Changed'));
        final member = (await StaffMembership.db.find(s)).first;
        await StaffMembership.db.updateRow(
          s,
          member.copyWith(displayName: 'Changed'),
        );
        expect(await SeedService.seedDemo(s), first);
        expect(
          (await Venue.db.findById(s, first.venueId))!.name,
          'Hawrys Rec Center (demo)',
        );
        expect(
          (await StaffMembership.db.findById(s, member.id!))!.displayName,
          isNot('Changed'),
        );
      },
    );

    test(
      'when an invalid seed secret is supplied then no rows are created',
      () async {
        await expectLater(
          endpoints.admin.seedDemo(builder, 'incorrect-secret'),
          throwsException,
        );
        expect(await Venue.db.count(builder.build()), 0);
      },
    );

    test(
      'when the configured seed secret is supplied then the endpoint seeds once',
      () async {
        final s = builder.build();
        final secret = s.passwords['seedSecret'];
        if (secret == null) {
          await expectLater(
            endpoints.admin.seedDemo(builder, ''),
            throwsException,
          );
          expect(await Venue.db.count(s), 0);
          return;
        }
        final result = await endpoints.admin.seedDemo(builder, secret);
        expect(
          (await Venue.db.findById(s, result.venueId))!.slug,
          'hawrys-demo',
        );
      },
    );
  });

  test('when no seed secret is configured then access stays disabled', () {
    expect(SeedService.acceptsSecret('', null), isFalse);
    expect(SeedService.acceptsSecret('', ''), isFalse);
    expect(SeedService.acceptsSecret('same', 'same'), isTrue);
    expect(SeedService.acceptsSecret('diff', 'same'), isFalse);
  });
}
