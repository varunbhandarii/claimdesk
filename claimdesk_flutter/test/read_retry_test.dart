import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/data/errors.dart';
import 'package:claimdesk_flutter/data/read_retry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

const fast = [Duration.zero, Duration.zero];

void main() {
  test('a read that hits a closed connection is sent again', () async {
    var calls = 0;
    final result = await retryReads('item', 'listItems', () async {
      if (++calls == 1) {
        throw const ServerpodClientNetworkException('Connection closed');
      }
      return 'items';
    }, delays: fast);
    expect(result, 'items');
    expect(calls, 2);
  });

  test('reads give up after the last retry', () async {
    var calls = 0;
    await expectLater(
      retryReads('match', 'inbox', () async {
        calls++;
        throw const ServerpodClientNetworkException('Offline');
      }, delays: fast),
      throwsA(isA<ServerpodClientNetworkException>()),
    );
    expect(calls, 3);
  });

  test('writes are never repeated', () async {
    for (final (endpoint, method) in [
      ('release', 'release'),
      ('match', 'confirm'),
      ('item', 'createItem'),
      ('item', 'transfer'),
      ('export', 'export'),
    ]) {
      var calls = 0;
      await expectLater(
        retryReads(endpoint, method, () async {
          calls++;
          throw const ServerpodClientNetworkException('Connection closed');
        }, delays: fast),
        throwsA(isA<ServerpodClientNetworkException>()),
      );
      expect(calls, 1, reason: '$endpoint.$method');
    }
  });

  test('refusals from the server are not retried', () async {
    var calls = 0;
    await expectLater(
      retryReads('item', 'getItem', () async {
        calls++;
        throw NotAMemberException(message: 'No access', venueId: venueId);
      }, delays: fast),
      throwsA(isA<NotAMemberException>()),
    );
    expect(calls, 1);
  });

  test('lost connections are left to the offline banner', () {
    expect(
      isConnectionError(const ServerpodClientNetworkException('Offline')),
      true,
    );
    expect(isConnectionError(Exception('Something else')), false);
  });
}
