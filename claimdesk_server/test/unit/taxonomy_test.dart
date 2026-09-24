import 'package:claimdesk_server/src/policy/taxonomy.dart';
import 'package:test/test.dart';

void main() {
  test(
    'all fine categories map to the 18 display groups and have unique lower-case synonyms',
    () {
      expect(Taxonomy.groups, hasLength(31));
      expect(Taxonomy.groups.values.toSet(), hasLength(18));
      expect(Taxonomy.synonyms.keys.toSet(), Taxonomy.groups.keys.toSet());
      for (final values in Taxonomy.synonyms.values) {
        expect(values.toSet().length, values.length);
        expect(values.every((v) => v == v.toLowerCase()), isTrue);
      }
      expect(Taxonomy.restricted, {
        'wallet_or_purse',
        'bank_card',
        'cash',
        'id_card_or_pass',
        'medical_device_or_medication',
        'jewellery',
      });
    },
  );
}
