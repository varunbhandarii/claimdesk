import 'dart:math';
import 'package:serverpod/serverpod.dart';

typedef LexicalResult = ({
  Map<UuidValue, ({double coverage, List<String> matched})> rows,
  int total,
});

class LexicalSearch {
  // Table, document and filter expressions are trusted server constants.
  // User text, tenant IDs and filter values are always bound parameters.
  static String sql({
    required String table,
    required String document,
    required String filter,
    int limit = 25,
    bool sortByFoundAt = false,
  }) {
    if (!{'found_item', 'lost_report'}.contains(table) ||
        limit < 1 ||
        limit > 100 ||
        (sortByFoundAt && table != 'found_item')) {
      throw ArgumentError('Invalid lexical query shape');
    }
    final extra = sortByFoundAt ? ', f."foundAt"' : '';
    final order = sortByFoundAt ? '"foundAt" DESC, "id"' : '"id"';
    final date = sortByFoundAt ? ', "foundAt"' : '';
    final emptyDate = sortByFoundAt ? ', NULL::timestamp' : '';
    return '''
      WITH q AS (SELECT tsvector_to_array(to_tsvector('english', @text)) AS qlex),
      scored AS (SELECT f."id"$extra,
        (SELECT count(*) FROM unnest(tsvector_to_array(to_tsvector('english', $document))) l
          WHERE l = ANY(q.qlex))::float / greatest(cardinality(q.qlex), 1) AS coverage,
        (SELECT array_agg(l) FROM unnest(tsvector_to_array(to_tsvector('english', $document))) l
          WHERE l = ANY(q.qlex)) AS matched
        FROM "$table" f, q WHERE f."venueId" = @venue::uuid AND $filter),
      tops AS (SELECT * FROM scored WHERE coverage > 0 ORDER BY coverage DESC, $order LIMIT $limit)
      SELECT "id", coverage, matched, cardinality(q.qlex)$date FROM tops, q
      UNION ALL SELECT NULL::uuid, 0::float, NULL::text[], cardinality(q.qlex)$emptyDate FROM q
      ${sortByFoundAt ? 'ORDER BY coverage DESC, "foundAt" DESC, "id"' : ''}
      ''';
  }

  static Future<LexicalResult> query(
    Session s, {
    required String table,
    required String document,
    required String filter,
    required String text,
    required UuidValue venueId,
    Map<String, dynamic> parameters = const {},
    int limit = 25,
    bool sortByFoundAt = false,
  }) async {
    final result = await s.db.unsafeQuery(
      sql(
        table: table,
        document: document,
        filter: filter,
        limit: limit,
        sortByFoundAt: sortByFoundAt,
      ),
      parameters: QueryParameters.named({
        ...parameters,
        'text': text,
        'venue': venueId.toString(),
      }),
    );
    final rows = <UuidValue, ({double coverage, List<String> matched})>{};
    var total = 0;
    for (final row in result) {
      total = (row[3] as num).toInt();
      if (row[0] != null) {
        final id = row[0] is UuidValue
            ? row[0] as UuidValue
            : UuidValue.fromString(row[0].toString());
        rows[id] = (
          coverage: (row[1] as num).toDouble(),
          matched: (row[2] as List?)?.cast<String>() ?? [],
        );
      }
    }
    return (rows: rows, total: max(0, total));
  }
}
