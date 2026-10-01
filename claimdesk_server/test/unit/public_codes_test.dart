import 'package:claimdesk_server/src/services/public_codes.dart';
import 'package:test/test.dart';

void main() {
  test(
    'references use the unambiguous alphabet and tokens have 128 random bits',
    () {
      final codes = PublicCodes();
      final tokens = <String>{};
      for (var i = 0; i < 2000; i++) {
        expect(codes.reference(), matches('^[${PublicCodes.alphabet}]{6}\$'));
        final token = codes.token();
        expect(token, matches(r'^[A-Za-z0-9_-]{22}$'));
        tokens.add(token);
      }
      expect(tokens, hasLength(2000));
    },
  );
  test('hash is stable and salted without exposing the address', () {
    final a = PublicCodes.ipHash('a' * 32, '127.0.0.1');
    expect(a, PublicCodes.ipHash('a' * 32, '127.0.0.1'));
    expect(a, isNot(PublicCodes.ipHash('b' * 32, '127.0.0.1')));
    expect(a, hasLength(64));
  });
}
