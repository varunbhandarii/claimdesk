import 'package:claimdesk_server/src/ai/caption_validator.dart';
import 'package:claimdesk_server/src/ai/text_template.dart';
import 'package:test/test.dart';
import 'caption_examples.dart';

void main() {
  test('template renders ordered fields and omits unknowns', () {
    final a = CaptionValidator.parse(
      captionExample(),
      modelId: 'fixture',
      promptVersion: 'caption_v1',
    );
    final text = TextTemplate.render(a.copyWith(brand: 'unknown'));
    expect(text, startsWith('Item: umbrella (brolly, parasol)\nColours:'));
    expect(
      text,
      contains(
        '\nMaterial: wood\nDistinguishing marks: wooden handle\nDescription:',
      ),
    );
    expect(text, isNot(contains('Brand:')));
  });
  test('restricted captions contain only category and synonyms', () {
    final a = CaptionValidator.parse(
      captionExample('mock_id_card'),
      modelId: 'fixture',
      promptVersion: 'caption_v1',
    );
    expect(TextTemplate.render(a).split('\n'), hasLength(1));
    expect(TextTemplate.render(a), startsWith('Item: id_card_or_pass'));
    expect(a.marks, isEmpty);
    expect(a.brand, isNull);
  });
}
