import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report states have desk labels', () {
    expect(ReportStatus.values.map(reportStatusLabel).toList(), [
      'Received',
      'Searching',
      'Possible match',
      'Ready for pickup',
      'Returned',
      'Closed',
    ]);
  });
}
