import 'package:claimdesk_server/src/matching/lexical_search.dart';
import 'package:claimdesk_server/src/services/item_search.dart';
import 'package:test/test.dart';

void main() {
  test(
    'candidate query keeps its coverage denominator, scope, limit and stable tie break',
    () {
      final sql = LexicalSearch.sql(
        table: 'found_item',
        document: 'f."captionText"',
        filter: 'f."foundAt" BETWEEN @lo AND @hi',
      );
      expect(sql, contains('greatest(cardinality(q.qlex), 1)'));
      expect(
        sql,
        contains(
          'f."venueId" = @venue::uuid AND f."foundAt" BETWEEN @lo AND @hi',
        ),
      );
      expect(sql, contains('ORDER BY coverage DESC, "id" LIMIT 25'));
      expect(
        sql,
        contains(
          'UNION ALL SELECT NULL::uuid, 0::float, NULL::text[], cardinality(q.qlex)',
        ),
      );
      expect(sql, isNot(contains('foundAt" DESC')));
    },
  );
  test(
    'staff search uses the same coverage over all three staff fields and date ordering',
    () {
      final sql = LexicalSearch.sql(
        table: 'found_item',
        document: ItemSearch.document,
        filter: 'f."zoneId" = @zone::uuid',
        limit: 50,
        sortByFoundAt: true,
      );
      for (final field in ['captionText', 'privateNotes', 'storageBin']) {
        expect(sql, contains('coalesce(f."$field", \'\')'));
      }
      expect(
        sql,
        contains('ORDER BY coverage DESC, "foundAt" DESC, "id" LIMIT 50'),
      );
      expect(sql, contains('@zone::uuid'));
      expect(
        () => LexicalSearch.sql(table: 'unsafe', document: 'x', filter: 'true'),
        throwsArgumentError,
      );
    },
  );
}
