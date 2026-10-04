import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/policy/item_titles.dart';
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
}
