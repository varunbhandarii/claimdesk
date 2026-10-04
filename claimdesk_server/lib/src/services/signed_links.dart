import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

class SignedLinks {
  static String key(Session s) {
    final value = s.passwords['serviceSecret'] ?? s.passwords['seedSecret'];
    if (value == null || value.isEmpty) {
      throw StateError('Upload signing is not configured');
    }
    return value;
  }

  static bool constantTimeEquals(String expected, String supplied) {
    if (expected.length != supplied.length) return false;
    var difference = 0;
    for (var n = 0; n < expected.length; n++) {
      difference |= expected.codeUnitAt(n) ^ supplied.codeUnitAt(n);
    }
    return difference == 0;
  }

  static String tagSignature(Session s, UuidValue item, int exp) => Hmac(
    sha256,
    utf8.encode(key(s)),
  ).convert(utf8.encode('tag|$item|$exp')).toString();
  static bool verifyTag(
    Session s,
    UuidValue item,
    String? expiration,
    String? signature, {
    DateTime? now,
  }) {
    if (expiration == null ||
        signature == null ||
        !RegExp(r'^\d{1,12}$').hasMatch(expiration) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(signature)) {
      return false;
    }
    final exp = int.parse(expiration),
        time = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
    if (exp <= time || exp > time + 86400) return false;
    return constantTimeEquals(tagSignature(s, item, exp), signature);
  }

  static Uri webUrl(Session s, String path, {Map<String, String>? query}) {
    final config = s.serverpod.config.webServer!;
    return Uri(
      scheme: config.publicScheme,
      host: config.publicHost,
      port: config.publicPort,
      path: path,
      queryParameters: query,
    );
  }

  static String tagUrl(Session s, UuidValue item, {DateTime? now}) {
    final exp =
        (now ?? DateTime.now())
            .toUtc()
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch ~/
        1000;
    return webUrl(
      s,
      '/tag/$item',
      query: {'exp': '$exp', 'sig': tagSignature(s, item, exp)},
    ).toString();
  }
}
