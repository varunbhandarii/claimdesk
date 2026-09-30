import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/status.dart';

void main() {
  test('all item states have staff wording and opaque colours', () {
    expect(ItemStatus.values.map(statusLabel), [
      'Logged',
      'Captioning',
      'On shelf',
      'Match proposed',
      'Returned',
      'Handed over',
      'Disposed',
      'Expired',
    ]);
    for (final status in ItemStatus.values) {
      expect(statusColour(status).a, 1);
      expect(statusLabel(status), isNot(status.name));
    }
  });
}
