import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

class UploadTickets {
  static String path(UuidValue venue, UuidValue item) =>
      'venues/$venue/items/$item.jpg';
  static String sign(
    Session s,
    UuidValue venue,
    UuidValue item,
    DateTime expires,
  ) {
    final key = s.passwords['serviceSecret'] ?? s.passwords['seedSecret'];
    if (key == null || key.isEmpty) {
      throw StateError('Upload signing is not configured');
    }
    final user = s.authenticated!.authUserId;
    return Hmac(sha256, utf8.encode(key))
        .convert(
          utf8.encode(
            '$user|$venue|$item|${expires.toUtc().microsecondsSinceEpoch}',
          ),
        )
        .toString();
  }

  static bool verify(
    Session s,
    UuidValue venue,
    UuidValue item,
    DateTime? expires,
    String? proof,
  ) {
    final now = DateTime.now().toUtc();
    if (expires == null ||
        proof == null ||
        !expires.isAfter(now) ||
        expires.isAfter(now.add(const Duration(minutes: 11)))) {
      return false;
    }
    final expected = sign(s, venue, item, expires);
    if (proof.length != expected.length) return false;
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected.codeUnitAt(i) ^ proof.codeUnitAt(i);
    }
    return difference == 0;
  }
}
