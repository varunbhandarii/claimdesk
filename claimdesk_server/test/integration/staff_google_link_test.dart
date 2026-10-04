import 'package:claimdesk_server/src/auth/staff_google_link.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/seed_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

GoogleAccountDetails details({
  String id = 'google-desk-lead',
  String email = 'Desk.Lead@Example.test',
  bool? verified = true,
}) => (
  userIdentifier: id,
  email: email,
  name: 'Desk',
  fullName: 'Desk Lead',
  image: null,
  verifiedEmail: verified,
);

void main() {
  withServerpod('Google sign-in for existing staff', (builder, _) {
    late Session s;
    late Venue venue;
    setUp(configureTestAuth);
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      await SeedService.ensureGoogleStaff(
        s,
        venueId: venue.id!,
        email: ' desk.lead@example.test ',
      );
    });

    Future<UuidValue> staffUser() async =>
        (await AuthServices.instance.emailIdp.admin.findAccount(
          s,
          email: 'desk.lead@example.test',
        ))!.authUserId;

    test('the seeded Google address is a passwordless supervisor', () async {
      final account = await EmailAccount.db.findFirstRow(
        s,
        where: (t) => t.email.equals('desk.lead@example.test'),
      );
      expect(account, isNotNull);
      expect(account!.passwordHash, isEmpty);
      final membership = await StaffMembership.db.findFirstRow(
        s,
        where: (t) => t.authUserId.equals(account.authUserId),
      );
      expect(membership!.role, StaffRole.supervisor);
      expect(membership.displayName, 'Desk lead');
      expect(membership.venueId, venue.id);
      await SeedService.ensureGoogleStaff(
        s,
        venueId: venue.id!,
        email: 'DESK.LEAD@example.test',
      );
      await SeedService.ensureGoogleStaff(s, venueId: venue.id!, email: '');
      await SeedService.ensureGoogleStaff(s, venueId: venue.id!, email: null);
      expect(await EmailAccount.db.count(s), 1);
      expect(await StaffMembership.db.count(s), 1);
    });

    test('a verified staff address links to the same user once', () async {
      await StaffGoogleLink.linkIfStaff(s, details());
      final linked = await GoogleAccount.db.find(s);
      expect(linked, hasLength(1));
      expect(linked.single.authUserId, await staffUser());
      expect(linked.single.email, 'desk.lead@example.test');
      await StaffGoogleLink.linkIfStaff(s, details());
      expect(await GoogleAccount.db.count(s), 1);
    });

    test('an already linked account signs in whatever its email', () async {
      await StaffGoogleLink.linkIfStaff(s, details());
      await StaffGoogleLink.linkIfStaff(
        s,
        details(email: 'changed@example.test', verified: false),
      );
      expect(await GoogleAccount.db.count(s), 1);
    });

    test('unverified, unknown and non-member addresses are refused', () async {
      final users = AuthServices.instance.authUsers;
      final outsider = await users.create(s);
      await AuthServices.instance.emailIdp.admin.createEmailAuthentication(
        s,
        authUserId: outsider.id,
        email: 'former@example.test',
        password: null,
      );
      for (final refused in [
        details(verified: false),
        details(verified: null),
        details(id: 'google-stranger', email: 'stranger@example.test'),
        details(id: 'google-former', email: 'former@example.test'),
      ]) {
        await expectLater(
          StaffGoogleLink.linkIfStaff(s, refused),
          throwsA(
            isA<NotStaffException>().having(
              (e) => e.message,
              'message',
              StaffGoogleLink.refusal,
            ),
          ),
        );
      }
      expect(await GoogleAccount.db.count(s), 0);
    });

    test('a user the provider would create on its own is rolled back', () {
      expect(
        () => StaffGoogleLink.refuseNewUser(
          s,
          AuthUserModel(
            id: actorId,
            createdAt: DateTime.now(),
            scopeNames: {},
            blocked: false,
          ),
          GoogleAccount(
            userIdentifier: 'google-new',
            email: 'new@example.test',
            authUserId: actorId,
          ),
          transaction: null,
        ),
        throwsA(isA<NotStaffException>()),
      );
    });
  });
}
