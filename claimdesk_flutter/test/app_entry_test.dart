import 'package:claimdesk_flutter/data/app_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'item entry accepts only a six-character reference before staff lookup',
    () {
      expect(
        itemEntry(Uri.parse('https://example.test/app/?item=seed01')),
        'SEED01',
      );
      for (final query in [
        '',
        '?item=short',
        '?item=12345678-1234-7123-8123-123456789abc',
        '?item=%3Cscript%3E',
      ]) {
        expect(itemEntry(Uri.parse('https://example.test/app/$query')), isNull);
      }
    },
  );
}
