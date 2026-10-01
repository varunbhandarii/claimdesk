import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/matching/match_chips_source.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    'de-stems matched lexemes into caption phrases and caps distinct results at six',
    () {
      final id = UuidValue.fromString('12345678-1234-7123-8123-123456789abc');
      final item = FoundItem(
        venueId: id,
        refCode: 'ITEM',
        loggedByAuthUserId: id,
        captionText:
            'black umbrella wooden handle curved nylon chipped folding canopy strap tip',
        attributes: ItemAttributes(
          category: 'umbrella',
          colours: ['black'],
          marks: ['wooden handle'],
          description: 'umbrella',
          containsPersonalData: false,
          personalDataKinds: [],
          keywords: [],
          source: 'fixture',
          modelId: 'fixture',
          promptVersion: 'fixture',
        ),
      );
      final result = displayKeywords([
        'black',
        'umbrella',
        'wooden',
        'handl',
        'curv',
        'nylon',
        'chip',
        'fold',
        'canopi',
        'strap',
        'tip',
      ], item);
      expect(result, contains('wooden handle'));
      expect(result, isNot(contains('handl')));
      expect(result, hasLength(6));
      expect(displayKeywords(['plastic'], item), isEmpty);
    },
  );
  test(
    'missing and low signals omit chips and only category and brand show differences',
    () {
      final e = MatchExplanation(
        matchedKeywords: ['wooden handle'],
        weightsHash: 'fixture',
        keywordCoverage: .6,
        category: 0,
        colour: 0,
        brand: 0,
        zone: .25,
        time: null,
      );
      expect(explanationChips(e).map((c) => c.text), [
        'category differs',
        'brand differs',
        'keyword: wooden handle',
      ]);
      expect(explanationChips(e.copyWith(keywordCoverage: .49)), hasLength(2));
    },
  );
}
