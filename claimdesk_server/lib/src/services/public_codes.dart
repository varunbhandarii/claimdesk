import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PublicCodes {
  PublicCodes({Random? random}) : random = random ?? Random.secure();
  final Random random;
  static const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  String reference() =>
      List.generate(6, (_) => alphabet[random.nextInt(alphabet.length)]).join();
  String token() => base64Url
      .encode(List.generate(16, (_) => random.nextInt(256)))
      .replaceAll('=', '');
  static String ipHash(String salt, String address) {
    if (salt.length < 32) throw StateError('IP privacy salt is not configured');
    return sha256.convert(utf8.encode('$salt$address')).toString();
  }

  static bool validToken(String token) =>
      RegExp(r'^[A-Za-z0-9_-]{22}$').hasMatch(token);
}
