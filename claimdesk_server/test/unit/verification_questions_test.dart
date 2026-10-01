import 'package:claimdesk_server/src/policy/verification_questions.dart';
import 'package:claimdesk_server/src/policy/taxonomy.dart';
import 'package:test/test.dart';

void main() {
  test('Every category asks two deterministic owner questions', () {
    for (final category in Taxonomy.groups.keys) {
      final questions = VerificationQuestions.forCategory(category);
      expect(questions, hasLength(2));
      expect(questions.last, VerificationQuestions.location);
      expect(questions.first, isNotEmpty);
    }
    expect(
      VerificationQuestions.forCategory('Bags'),
      VerificationQuestions.forCategory('backpack'),
    );
    expect(
      VerificationQuestions.forCategory('unknown').first,
      VerificationQuestions.fallback,
    );
  });
  test('Answers are trimmed and bounded independently', () {
    expect(VerificationQuestions.validate([' short ', 'x' * 301]).keys, [
      'answer1',
      'answer2',
    ]);
    expect(VerificationQuestions.validate(['x' * 10, 'x' * 300]), isEmpty);
  });
}
