import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/data/photo_urls.dart';
import 'fixtures.dart';

void main() {
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
