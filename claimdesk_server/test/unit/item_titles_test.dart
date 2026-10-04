import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/policy/item_titles.dart';
import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:claimdesk_server/src/web/public/public_views.dart';
import 'package:test/test.dart';

ItemAttributes attributes(String category, List<String> colours) =>
    ItemAttributes(
      category: category,
      colours: colours,
      marks: [],
      description: 'A private description that is never used in titles',
      personalDataKinds: [],
      keywords: [],
      source: 'fixture',
    );

void main() {
  test('titles name the first colour and the kind of item only', () {
    expect(
      ItemTitles.title(attributes('umbrella', ['black', 'brown'])),
      'Black umbrella',
    );
    expect(
      ItemTitles.title(attributes('toy_or_plush', ['multicolour'])),
      'Multicoloured plush toy',
    );
    expect(ItemTitles.title(attributes('keys', [])), 'Keys');
    expect(
      ItemTitles.title(attributes('other', ['transparent'])),
      'Clear item',
    );
    expect(ItemTitles.title(null), 'Found item');
    expect(
      ItemTitles.title(attributes('other', [])),
      isNot(contains('private')),
    );
  });
  test('swatch names and short days read naturally', () {
    expect(swatchName('multicolour'), 'Multi');
    expect(swatchName('transparent'), 'Clear');
    expect(swatchName('navy'), 'Navy');
    expect(shortDay(DateTime(2026, 9, 30)), 'Sep 30');
    expect(
      shortDay(DateTime(2025, 12, 31), now: DateTime(2026, 1, 2)),
      'Dec 31, 2025',
    );
  });
  test('Spanish titles put the noun first and agree with it', () {
    final cases = {
      ('umbrella', 'black'): 'Paraguas negro',
      ('backpack', 'black'): 'Mochila negra',
      ('keys', 'red'): 'Llaves rojas',
      ('footwear', 'white'): 'Zapatos blancos',
      ('earbuds_or_headphones', 'grey'): 'Audífonos grises',
      ('toy_or_plush', 'multicolour'): 'Peluche multicolor',
      ('glasses_or_sunglasses', 'multicolour'): 'Lentes multicolores',
      ('water_bottle_or_flask', 'transparent'): 'Botella de agua transparente',
      ('jacket_or_coat', 'navy'): 'Chaqueta azul marino',
      ('hat_or_cap', 'brown'): 'Gorra café',
      ('other', 'yellow'): 'Objeto amarillo',
    };
    cases.forEach((input, title) {
      expect(
        ItemTitles.spanishTitle(attributes(input.$1, [input.$2])),
        title,
      );
    });
    expect(ItemTitles.spanishTitle(attributes('keys', [])), 'Llaves');
    expect(ItemTitles.spanishTitle(null), 'Objeto encontrado');
  });
  test('Spanish swatch names and short days', () {
    expect(swatchName('brown', lang: PublicLang.es), 'Café');
    expect(swatchName('navy', lang: PublicLang.es), 'Azul marino');
    expect(shortDay(DateTime(2026, 9, 30), lang: PublicLang.es), '30 sept');
    expect(
      shortDay(
        DateTime(2025, 12, 31),
        now: DateTime(2026, 1, 2),
        lang: PublicLang.es,
      ),
      '31 dic 2025',
    );
  });
}
