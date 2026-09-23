import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:test/test.dart';

Map<String, dynamic> readFixture(String name) =>
    jsonDecode(File('test/fixtures/providers/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('Saved item captions', () {
    for (final entry in {
      'umbrella': 'umbrella',
      'backpack': 'backpack',
      'mock_id_card': 'id_document',
    }.entries) {
      test('${entry.key} preserves the expected structured response', () {
        final response = readFixture('claude_caption_${entry.key}');
        expect(response['model'], 'claude-opus-5-5');
        expect(response['stop_reason'], 'end_turn');
        final text =
            (response['content'] as List)
                    .cast<Map<String, dynamic>>()
                    .singleWhere((block) => block['type'] == 'text')['text']
                as String;
        final caption = jsonDecode(text) as Map<String, dynamic>;
        expect(
          caption.keys,
          unorderedEquals([
            'category',
            'colours',
            'description',
            'contains_personal_data',
          ]),
        );
        expect(caption['category'], entry.value);
        expect(caption['colours'], everyElement(isA<String>()));
        expect(caption['contains_personal_data'], isA<bool>());
        expect(caption['description'], isA<String>());
        if (entry.key == 'mock_id_card') {
          expect(caption['contains_personal_data'], isTrue);
          expect(caption['description'], 'Personal document');
          expect(caption['colours'], isEmpty);
        }
      });
    }
  });

  test('Saved embeddings retain 1536 finite, normalized values', () {
    for (final name in ['umbrella', 'repeat', 'query']) {
      final response = readFixture('gemini_embed_$name');
      checkVector((response['embedding'] as Map)['values']);
    }
    final batch = readFixture('gemini_embed_batch')['embeddings'] as List;
    expect(batch, hasLength(2));
    for (final embedding in batch) {
      checkVector((embedding as Map)['values']);
    }
    expect(
      readFixture('gemini_embed_repeat')['embedding'],
      readFixture('gemini_embed_umbrella')['embedding'],
    );
  });
}

void checkVector(dynamic raw) {
  expect(raw, isA<List>());
  final values = (raw as List).cast<num>();
  expect(values, hasLength(1536));
  expect(values.every((value) => value.isFinite), isTrue);
  final norm = math.sqrt(
    values.fold<double>(0, (sum, value) => sum + value * value),
  );
  expect(norm, closeTo(1, 0.001));
}
