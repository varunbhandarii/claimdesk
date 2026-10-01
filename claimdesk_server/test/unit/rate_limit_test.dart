import 'dart:io';
import 'package:claimdesk_server/src/web/middleware/rate_limit.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

// The pinned transport exposes no public constructor for handler-only tests.

void main() {
  test('sliding window separates addresses and expires at the boundary', () {
    final clock = DateTime.utc(2026, 9, 30);
    final limiter = SlidingWindow(
      limit: 10,
      window: const Duration(minutes: 10),
    );
    for (var i = 0; i < 10; i++) {
      expect(limiter.retryAfter('a', clock), isNull);
    }
    expect(limiter.retryAfter('a', clock), 600);
    expect(limiter.retryAfter('b', clock), isNull);
    expect(
      limiter.retryAfter('a', clock.add(const Duration(minutes: 10))),
      isNull,
    );
  });
  test(
    'middleware counts only selected methods and returns retry headers',
    () async {
      await templates.loadAll(Directory('web/templates'));
      final clock = DateTime.utc(2026, 9, 30);
      final handler = rateLimit(
        limit: 1,
        window: const Duration(minutes: 10),
        methods: {Method.post},
        trustProxy: false,
        salt: 'test-only-salt-32-characters-long',
        now: () => clock,
      )((_) => Response.ok());
      Request req(Method method) => RequestInternal.create(
        method,
        Uri.parse('http://localhost/v/test/lost'),
        Object(),
      );
      expect((await handler(req(Method.get)) as Response).statusCode, 200);
      expect((await handler(req(Method.post)) as Response).statusCode, 200);
      final blocked = await handler(req(Method.post)) as Response;
      expect(blocked.statusCode, 429);
      expect(blocked.headers['retry-after'], ['600']);
    },
  );
}
