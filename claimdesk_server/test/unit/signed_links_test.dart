import 'package:claimdesk_server/src/services/signed_links.dart';
import 'package:test/test.dart';

void main() {
  test(
    'constant-time equality handles equal, tampered and unequal length inputs',
    () {
      expect(SignedLinks.constantTimeEquals('a' * 64, 'a' * 64), true);
      expect(SignedLinks.constantTimeEquals('a' * 64, 'b${'a' * 63}'), false);
      expect(SignedLinks.constantTimeEquals('a' * 64, 'a' * 63 + 'b'), false);
      expect(SignedLinks.constantTimeEquals('a' * 64, 'a' * 63), false);
    },
  );
}
