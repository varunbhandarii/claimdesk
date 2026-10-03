import 'package:claimdesk_server/src/matching/apply_profile.dart';
import 'package:test/test.dart';

void main() {
  test('matching profile contains only a reference and numeric fields', () {
    final profile = ApplyProfile()..applyAttempts = 2;
    final line = profile.line('SEED01', draft: false);
    expect(line, startsWith('Matching profile report=SEED01 '));
    for (final field in line.split(' ').skip(3)) {
      expect(field, matches(r'^[A-Za-z]+=\d+$'));
    }
    expect(line, contains('serializationRetries=1'));
    expect(line, endsWith('draft=0'));
    expect(
      () => profile.line('owner@example.test', draft: true),
      throwsArgumentError,
    );
  });
}
