import 'dart:convert';
import 'dart:io';

/// Adapts the saved compact provider samples to the full caption contract.
Map<String, dynamic> captionExample([String fixture = 'umbrella']) {
  final response = jsonDecode(
    File(
      'test/fixtures/providers/claude_caption_$fixture.json',
    ).readAsStringSync(),
  );
  final text = (response['content'] as List).firstWhere(
    (b) => b['type'] == 'text',
  )['text'];
  final sample = jsonDecode(text);
  final personal = sample['contains_personal_data'] as bool;
  return {
    'items': [
      {
        'category': personal ? 'id_card_or_pass' : sample['category'],
        'category_confidence': .95,
        'colours': sample['colours'],
        'brand': null,
        'material': personal ? null : 'wood',
        'marks': fixture == 'umbrella' ? ['wooden handle'] : <String>[],
        'description': sample['description'],
        'confidence': .95,
      },
    ],
    'primary_item_index': 0,
    'contains_personal_data': personal,
    'personal_data_kinds': personal ? ['id_document'] : <String>[],
    'image_quality': 'good',
  };
}

Map<String, Object> claudeBody({
  String stop = 'end_turn',
  String model = 'claude-opus-5-5',
}) => {
  'model': model,
  'stop_reason': stop,
  'content': [
    {'type': 'thinking', 'thinking': ''},
    {'type': 'text', 'text': jsonEncode(captionExample())},
  ],
  'usage': {'input_tokens': 500, 'output_tokens': 100},
};
