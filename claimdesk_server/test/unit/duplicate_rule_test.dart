import 'package:claimdesk_server/src/services/duplicate_rule.dart';
import 'package:test/test.dart';

void main() {
  test('overlap is case and punctuation insensitive at the threshold', () {
    expect(
      DuplicateRule.overlap(
        'ONE, TWO three four five six seven eight nine ten',
        'one two three four five six seven',
      ),
      .7,
    );
    expect(DuplicateRule.overlap('a b c d', 'a b'), .5);
  });
  test('same nonnull category wins only inside the 24 hour window', () {
    final now = DateTime.utc(2026, 9, 30);
    bool check(DateTime previous, String? category) => DuplicateRule.matches(
      category: category,
      previousCategory: category,
      text: 'completely different',
      previousText: 'other words',
      previousCreatedAt: previous,
      now: now,
    );
    expect(check(now.subtract(const Duration(hours: 24)), 'umbrella'), isTrue);
    expect(
      check(
        now.subtract(const Duration(hours: 24, microseconds: 1)),
        'umbrella',
      ),
      isFalse,
    );
    expect(check(now, null), isFalse);
  });
}
