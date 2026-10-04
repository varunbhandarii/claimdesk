import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/data/errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sign-in refusals read as plain sentences', () {
    const refusal =
        'This Google account is not on a desk team. Ask your supervisor to add you.';
    expect(errorMessage(NotStaffException(message: refusal)), refusal);
    expect(errorMessage(Exception('Something odd')), 'Something odd');
  });
}
