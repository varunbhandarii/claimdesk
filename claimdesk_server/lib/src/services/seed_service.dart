import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../policy/retention.dart';

class SeedService {
  static const supervisorEmail = 'supervisor@demo.claimdesk.local';
  static const staffEmail = 'staff@demo.claimdesk.local';
  static const zoneNames = [
    'Front desk',
    'Gym floor',
    'Pool deck',
    'Locker rooms',
    'Courts',
    'Parking',
  ];

  /// Returns stable ids without changing existing account passwords.
  static Future<
    ({UuidValue venueId, UuidValue supervisorId, UuidValue staffId})
  >
  seedDemo(Session session) async {
    final password =
        session.passwords['demoStaffPassword'] ??
        (session.serverpod.runMode == ServerpodRunMode.development ||
                session.serverpod.runMode == ServerpodRunMode.test
            ? 'local-demo-only-change-me'
            : null);
    if (password == null || password.isEmpty) {
      throw StateError('Demo staff password is not configured');
    }
    return session.db.transaction((tx) async {
      // Serialize concurrent seed requests, including the first venue insert.
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(91375201)',
        transaction: tx,
      );
      var venue = await Venue.db.findFirstRow(
        session,
        where: (t) => t.slug.equals('hawrys-demo'),
        transaction: tx,
      );
      final desired = Venue(
        id: venue?.id,
        name: 'Hawrys Rec Center (demo)',
        slug: 'hawrys-demo',
        deskHours: 'Mon–Fri 7:00–22:00, Sat–Sun 9:00–20:00',
        pickupInstructions: 'Front desk, bring photo ID',
        retentionPolicy: defaultRetentionPolicy(),
        createdAt: venue?.createdAt,
      );
      venue = venue == null
          ? await Venue.db.insertRow(session, desired, transaction: tx)
          : await Venue.db.updateRow(session, desired, transaction: tx);
      final venueId = venue.id!;
      final zones = <String, Zone>{};
      for (var i = 0; i < zoneNames.length; i++) {
        final name = zoneNames[i];
        var zone = await Zone.db.findFirstRow(
          session,
          where: (t) => t.venueId.equals(venueId) & t.name.equals(name),
          transaction: tx,
        );
        zone ??= await Zone.db.insertRow(
          session,
          Zone(venueId: venueId, name: name, sortOrder: i, adjacentZoneIds: []),
          transaction: tx,
        );
        zones[name] = zone;
      }
      final adjacency = <String, List<String>>{
        'Front desk': ['Gym floor', 'Locker rooms'],
        'Gym floor': ['Front desk'],
        'Pool deck': ['Locker rooms'],
        'Locker rooms': ['Front desk', 'Pool deck'],
      };
      for (var i = 0; i < zoneNames.length; i++) {
        final zone = zones[zoneNames[i]]!;
        await Zone.db.updateRow(
          session,
          zone.copyWith(
            sortOrder: i,
            adjacentZoneIds: [
              for (final name in adjacency[zone.name] ?? <String>[])
                zones[name]!.id!,
            ],
          ),
          transaction: tx,
        );
      }
      final supervisorId = await _ensureStaff(
        session,
        tx,
        venueId: venueId,
        email: supervisorEmail,
        password: password,
        displayName: 'Sam Supervisor',
        role: StaffRole.supervisor,
      );
      final staffId = await _ensureStaff(
        session,
        tx,
        venueId: venueId,
        email: staffEmail,
        password: password,
        displayName: 'Riley Staff',
        role: StaffRole.staff,
      );
      return (venueId: venueId, supervisorId: supervisorId, staffId: staffId);
    });
  }

  static Future<UuidValue> _ensureStaff(
    Session session,
    Transaction tx, {
    required UuidValue venueId,
    required String email,
    required String password,
    required String displayName,
    required StaffRole role,
  }) async {
    final auth = AuthServices.instance;
    final admin = auth.emailIdp.admin;
    final existing = await admin.findAccount(
      session,
      email: email,
      transaction: tx,
    );
    final userId =
        existing?.authUserId ??
        (await auth.authUsers.create(session, transaction: tx)).id;
    if (existing == null) {
      await admin.createEmailAuthentication(
        session,
        authUserId: userId,
        email: email,
        password: password,
        transaction: tx,
      );
    }
    final membership = await StaffMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId) & t.venueId.equals(venueId),
      transaction: tx,
    );
    if (membership == null) {
      await StaffMembership.db.insertRow(
        session,
        StaffMembership(
          authUserId: userId,
          venueId: venueId,
          role: role,
          displayName: displayName,
        ),
        transaction: tx,
      );
    } else if (membership.role != role ||
        membership.displayName != displayName) {
      await StaffMembership.db.updateRow(
        session,
        membership.copyWith(role: role, displayName: displayName),
        transaction: tx,
      );
    }
    return userId;
  }

  /// Constant-time comparison for equal-length credentials; never logs input.
  static bool acceptsSecret(String supplied, String? expected) {
    if (expected == null || expected.isEmpty) return false;
    final a = utf8.encode(supplied);
    final b = utf8.encode(expected);
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
