import 'package:claimdesk_server/src/ai/caption_validator.dart';
import 'package:test/test.dart';
import 'caption_examples.dart';

void main() {
  for (final fixture in ['umbrella', 'backpack', 'mock_id_card']) {
    test('saved $fixture content validates in the full caption envelope', () {
      final a = CaptionValidator.parse(
        captionExample(fixture),
        modelId: 'fixture',
        promptVersion: 'caption_v1',
      );
      expect(
        a.category,
        fixture == 'mock_id_card' ? 'id_card_or_pass' : fixture,
      );
    });
  }
  for (final invalid in [
    'category',
    'colours',
    'marks',
    'description',
    'index',
    'confidence',
    'extra',
  ]) {
    test('rejects invalid $invalid', () {
      final data = captionExample();
      final item = data['items'][0] as Map;
      switch (invalid) {
        case 'category':
          item['category'] = 'made_up';
        case 'colours':
          item['colours'] = ['black', 'blue', 'red', 'green'];
        case 'marks':
          item['marks'] = List.filled(6, 'mark');
        case 'description':
          item['description'] = '';
        case 'index':
          data['primary_item_index'] = 3;
        case 'confidence':
          item['confidence'] = 2;
        case 'extra':
          item['extra'] = 'unrecognized';
      }
      expect(
        () => CaptionValidator.parse(
          data,
          modelId: 'x',
          promptVersion: 'caption_v1',
        ),
        throwsFormatException,
      );
    });
  }
  test('personal data is removed from searchable text and metadata', () {
    final data = captionExample();
    data['contains_personal_data'] = true;
    data['personal_data_kinds'] = ['name_text'];
    data['items'][0]['description'] = 'Jane 12345';
    data['items'][0]['marks'] = ['Name Jane 5551234'];
    data['items'][0]['brand'] = 'Jane 123';
    final a = CaptionValidator.parse(
      data,
      modelId: 'x',
      promptVersion: 'caption_v1',
    );
    expect(a.description, 'umbrella');
    expect(a.marks, isEmpty);
    expect(a.brand, isNull);
    expect(a.toJson().toString(), isNot(contains('Jane')));
    expect(a.toJson().toString(), isNot(contains('123')));
  });
}
