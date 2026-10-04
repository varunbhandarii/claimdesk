import 'dart:io';
import 'package:claimdesk_server/src/policy/taxonomy.dart';
import 'package:claimdesk_server/src/policy/verification_questions.dart';
import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:claimdesk_server/src/web/public/public_strings.dart';
import 'package:test/test.dart';

Set<String> placeholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m[1]!).toSet();

void main() {
  test('both languages have the same keys, text and placeholders', () {
    expect(PublicStrings.es.keys.toSet(), PublicStrings.en.keys.toSet());
    for (final key in PublicStrings.en.keys) {
      final en = PublicStrings.en[key]!, es = PublicStrings.es[key]!;
      expect(en.trim(), isNotEmpty, reason: key);
      expect(es.trim(), isNotEmpty, reason: key);
      expect(placeholders(es), placeholders(en), reason: key);
    }
    expect(PublicStrings.of(PublicLang.es), same(PublicStrings.es));
    expect(PublicStrings.of(PublicLang.en), same(PublicStrings.en));
  });

  test('every key a template reads exists', () {
    final used = <String>{};
    for (final file in Directory('web/templates/public').listSync()) {
      if (file is! File || !file.path.endsWith('.html')) continue;
      used.addAll(
        RegExp(
          r'\{\{\s*(?:en|es|t)\.(\w+)\s*\}\}',
        ).allMatches(file.readAsStringSync()).map((m) => m[1]!),
      );
    }
    expect(used, isNotEmpty);
    expect(used.difference(PublicStrings.en.keys.toSet()), isEmpty);
  });

  test('categories, colours and questions all read in Spanish', () {
    for (final group in {...Taxonomy.groups.values}) {
      expect(PublicStrings.groupsEs, contains(group), reason: group);
      expect(PublicStrings.group(group, PublicLang.en), group);
    }
    expect(PublicStrings.swatchesEs.keys.toSet(), Taxonomy.colours.toSet());
    final questions = {
      for (final category in [...Taxonomy.groups.keys, 'other', 'unknown'])
        ...VerificationQuestions.forCategory(category),
    };
    for (final question in questions) {
      expect(PublicStrings.questionsEs, contains(question), reason: question);
      expect(PublicStrings.question(question, PublicLang.en), question);
    }
    expect(
      PublicStrings.question('A question saved earlier', PublicLang.es),
      'A question saved earlier',
    );
  });

  test('placeholders fill by name', () {
    expect(
      PublicStrings.fill(PublicStrings.es['stepOf']!, {'n': 3, 'count': 5}),
      'Paso 3 de 5',
    );
    expect(
      PublicStrings.fill(PublicStrings.en['errMax']!, {'max': 60}),
      'Use at most 60 characters.',
    );
  });
}
