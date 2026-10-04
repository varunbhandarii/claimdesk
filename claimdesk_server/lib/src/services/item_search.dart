import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../matching/lexical_search.dart';
import '../policy/taxonomy.dart';
import 'item_attention.dart';
import 'staff_views.dart';

class ItemSearch {
  static const document =
      '''coalesce(f."captionText", '') || ' ' || coalesce(f."privateNotes", '') || ' ' || coalesce(f."storageBin", '')''';
  static bool category(FoundItem row, String? value) =>
      value == null ||
      row.attributes?.category == value ||
      (row.attributes != null &&
          Taxonomy.rollUp(row.attributes!.category) == value);
  static Future<List<FoundItem>> find(
    Session s,
    UuidValue venue,
    String query,
    ItemFilter filter,
  ) async {
    final now = DateTime.now().toUtc();
    ItemAttention.condition(FoundItem.t, filter.attention, now);
    final clauses = <String>[
      filter.status != null
          ? 'f."status" = @status'
          : filter.attention == 'overdue'
          ? 'true'
          : '''f."status" NOT IN ('disposed','expired')''',
      if (filter.zoneId != null) 'f."zoneId" = @zone::uuid',
      if (filter.attention == 'overdue')
        '''f."status" IN ('unclaimed','matched','expired') AND f."handoffDueAt" < @now''',
      if (filter.attention == 'expiringSoon')
        '''f."status" = 'unclaimed' AND f."holdUntil" BETWEEN @now AND @soon''',
      if (filter.attention == 'captioningFailed')
        '''f."status" = 'captioning' AND EXISTS (SELECT 1 FROM "work_item" w
        WHERE w."venueId" = f."venueId" AND w."kind" = 'caption_item' AND w."state" = 'failed' AND w."identifier" = 'caption_' || f."id"::text)''',
    ];
    final refs = RegExp(r'^[A-Z0-9]{6}$').hasMatch(query.toUpperCase())
        ? await FoundItem.db.find(
            s,
            where: (t) =>
                ItemAttention.filter(t, venue, filter, now) &
                t.refCode.equals(query.toUpperCase()),
            limit: 1,
          )
        : <FoundItem>[];
    final lexical = await LexicalSearch.query(
      s,
      table: 'found_item',
      document: document,
      filter: clauses.join(' AND '),
      text: Taxonomy.canonicalize(query),
      venueId: venue,
      limit: 50,
      sortByFoundAt: true,
      parameters: {
        'status': ?filter.status?.name,
        'zone': ?filter.zoneId?.toString(),
        if (filter.attention == 'overdue' || filter.attention == 'expiringSoon')
          'now': now,
        if (filter.attention == 'expiringSoon')
          'soon': now.add(const Duration(days: 3)),
      },
    );
    final found = lexical.rows.isEmpty
        ? <FoundItem>[]
        : await FoundItem.db.find(
            s,
            where: (t) =>
                t.id.inSet(lexical.rows.keys.toSet()) &
                ItemAttention.filter(t, venue, filter, now),
          );
    final byId = {for (final row in found) row.id!: row};
    final ordered = <UuidValue, FoundItem>{
      for (final row in refs) row.id!: row,
      for (final id in lexical.rows.keys)
        if (byId[id] != null) id: byId[id]!,
    };
    return ordered.values
        .where((r) => category(r, filter.category))
        .take(50)
        .map(StaffViews.item)
        .toList();
  }
}
