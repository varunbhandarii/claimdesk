import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/data/photo_urls.dart';
import 'fixtures.dart';

void main() {
  test(
    'Signature URLs have a separate short-lived cache and are invalidated with the item',
    () async {
      var calls = 0;
      final urls = PhotoUrls(
        (_, _) async => 'https://example.test/photo',
        fetchSignature: (_) async {
          calls++;
          return 'https://example.test/signature';
        },
      );
      await urls.get(itemId);
      expect(await urls.signature(itemId), 'https://example.test/signature');
      await urls.signature(itemId);
      expect(calls, 1);
      urls.invalidate(itemId);
      await urls.signature(itemId);
      expect(calls, 2);
      urls.dispose();
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'shares in-flight requests, refetches disposable URLs and clears on sign-out',
    () async {
      var calls = 0;
      final pending = Completer<String?>();
      final urls = PhotoUrls((id, thumb) {
        calls++;
        return pending.future;
      });
      final first = urls.get(itemId, thumb: true);
      final second = urls.get(itemId, thumb: true);
      expect(calls, 1);
      pending.complete('https://example.test/private-photo');
      expect(await first, await second);
      await urls.get(itemId, thumb: true);
      expect(calls, 1);
      await urls.get(itemId, thumb: true, fresh: true);
      expect(calls, 2);
      urls.invalidate(itemId);
      await urls.get(itemId, thumb: true);
      expect(calls, 3);
      urls.dispose();
    },
  );
  test(
    'missing thumbnails are not cached while the job creates them',
    () async {
      var calls = 0;
      final urls = PhotoUrls(
        (id, thumb) async => ++calls == 1 ? null : 'https://example.test/thumb',
      );
      expect(await urls.get(itemId, thumb: true), isNull);
      expect(await urls.get(itemId, thumb: true), isNotNull);
      expect(calls, 2);
      urls.dispose();
    },
  );
}
