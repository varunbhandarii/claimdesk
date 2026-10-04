import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'record_history.dart';

typedef ExportRows = ({List<String> header, List<List<Object?>> rows});

class VenueExports {
  static const headers = <String, List<String>>{
    'items': [
      'reference',
      'status',
      'category',
      'colours',
      'brand',
      'description',
      'zone',
      'bin',
      'value band',
      'restricted',
      'found at',
      'hold until',
      'hand-off due',
      'logged by',
      'current location',
      'created',
      'updated',
    ],
    'reports': [
      'reference',
      'status',
      'category hint',
      'colours',
      'brand hint',
      'zone',
      'where',
      'lost at',
      'fuzzy days',
      'contact email',
      'owner name',
      'created',
      'closed',
      'contact purged at',
    ],
    'matches': [
      'report reference',
      'item reference',
      'state',
      'score',
      'label',
      'rank',
      'algorithm version',
      'decided by',
      'decided at',
      'created',
    ],
    'releases': [
      'item reference',
      'report reference',
      'claimant name',
      'ID type',
      'details matched',
      'described before viewing',
      'third-party note',
      'released by',
      'released at',
    ],
    'custody': ['item reference', 'from', 'to', 'reference', 'by', 'at'],
  };
  static Future<List<T>> pages<T>(Future<List<T>> Function(int) fetch) async {
    final rows = <T>[];
    for (var offset = 0; offset < 10000; offset += 100) {
      final page = await fetch(offset);
      rows.addAll(page);
      if (page.length < 100) break;
    }
    return rows.take(10000).toList();
  }

  static Future<ExportRows> build(
    Session s,
    UuidValue venue,
    String kind,
  ) async {
    if (!headers.containsKey(kind)) throw ArgumentError('Unknown export kind');
    final items = kind == 'items'
        ? await pages(
            (offset) => FoundItem.db.find(
              s,
              where: (t) => t.venueId.equals(venue),
              orderBy: (t) => t.id,
              limit: 100,
              offset: offset,
            ),
          )
        : <FoundItem>[];
    final reports = kind == 'reports'
        ? await pages(
            (offset) => LostReport.db.find(
              s,
              where: (t) => t.venueId.equals(venue),
              orderBy: (t) => t.id,
              limit: 100,
              offset: offset,
            ),
          )
        : <LostReport>[];
    final matches = kind == 'matches'
        ? await pages(
            (offset) => ItemMatch.db.find(
              s,
              where: (t) => t.venueId.equals(venue),
              orderBy: (t) => t.id,
              limit: 100,
              offset: offset,
            ),
          )
        : <ItemMatch>[];
    final releases = kind == 'releases'
        ? await pages(
            (offset) => ReleaseRecord.db.find(
              s,
              where: (t) => t.venueId.equals(venue),
              orderBy: (t) => t.id,
              limit: 100,
              offset: offset,
            ),
          )
        : <ReleaseRecord>[];
    final custody = kind == 'custody'
        ? await pages(
            (offset) => CustodyEvent.db.find(
              s,
              where: (t) => t.venueId.equals(venue),
              orderBy: (t) => t.id,
              limit: 100,
              offset: offset,
            ),
          )
        : <CustodyEvent>[];
    final itemIds = {
      ...matches.map((m) => m.itemId),
      ...releases.map((r) => r.itemId),
      ...custody.map((c) => c.itemId),
    };
    final reportIds = {
      ...matches.map((m) => m.reportId),
      for (final r in releases)
        if (r.reportId != null) r.reportId!,
    };
    final relatedItems = itemIds.isEmpty
        ? <FoundItem>[]
        : await FoundItem.db.find(
            s,
            where: (t) => t.venueId.equals(venue) & t.id.inSet(itemIds),
          );
    final relatedReports = reportIds.isEmpty
        ? <LostReport>[]
        : await LostReport.db.find(
            s,
            where: (t) => t.venueId.equals(venue) & t.id.inSet(reportIds),
          );
    final itemRefs = {for (final i in relatedItems) i.id!: i.refCode};
    final reportRefs = {for (final r in relatedReports) r.id!: r.refCode};
    final names = await StaffActors.names(s, venue, {
      ...items.map((i) => i.loggedByAuthUserId),
      for (final m in matches)
        if (m.decidedByAuthUserId != null) m.decidedByAuthUserId!,
      ...releases.map((r) => r.releasedByAuthUserId),
      ...custody.map((c) => c.byAuthUserId),
    });
    String actor(UuidValue id) => StaffActors.name(names, id);
    final zones = (kind == 'items' || kind == 'reports')
        ? await Zone.db.find(s, where: (t) => t.venueId.equals(venue))
        : <Zone>[];
    final zoneNames = {for (final z in zones) z.id!: z.name};
    final locations = <String, String>{};
    if (items.isNotEmpty) {
      final rows = await s.db.unsafeQuery(
        '''SELECT DISTINCT ON ("itemId") "itemId", "toLocation" FROM "custody_event"
        WHERE "venueId" = @venue::uuid AND "itemId" = ANY(@ids::uuid[]) ORDER BY "itemId", "at" DESC, "id" DESC''',
        parameters: QueryParameters.named({
          'venue': venue.toString(),
          'ids': items.map((i) => i.id.toString()).toList(),
        }),
      );
      for (final row in rows) {
        locations[row[0].toString()] = row[1] as String;
      }
    }
    return (
      header: headers[kind]!,
      rows: switch (kind) {
        'items' => [
          for (final i in items)
            [
              i.refCode,
              i.status.name,
              i.attributes?.category,
              i.attributes?.colours.join(' | '),
              i.attributes?.brand,
              i.attributes?.description,
              zoneNames[i.zoneId],
              i.storageBin,
              i.valueBand.name,
              i.restricted,
              i.foundAt,
              i.holdUntil,
              i.handoffDueAt,
              actor(i.loggedByAuthUserId),
              locations[i.id.toString()] ?? 'desk',
              i.createdAt,
              i.updatedAt,
            ],
        ],
        'reports' => [
          for (final r in reports)
            [
              r.refCode,
              r.status.name,
              r.categoryHint,
              r.colourHints.join(' | '),
              r.brandHint,
              zoneNames[r.zoneId],
              r.whereText,
              r.lostAt,
              r.lostAtFuzzyDays,
              r.contactEmail,
              r.ownerName,
              r.createdAt,
              r.closedAt,
              r.contactPurgedAt,
            ],
        ],
        'matches' => [
          for (final m in matches)
            [
              reportRefs[m.reportId],
              itemRefs[m.itemId],
              m.state.name,
              m.score,
              m.label,
              m.rank,
              m.algorithmVersion,
              m.decidedByAuthUserId == null
                  ? null
                  : actor(m.decidedByAuthUserId!),
              m.decidedAt,
              m.createdAt,
            ],
        ],
        'releases' => [
          for (final r in releases)
            [
              itemRefs[r.itemId],
              reportRefs[r.reportId],
              r.claimantName,
              r.idTypeSeen,
              r.detailsMatched,
              r.describedBeforeViewing,
              r.thirdPartyAuthorisationNote,
              actor(r.releasedByAuthUserId),
              r.releasedAt,
            ],
        ],
        'custody' => [
          for (final c in custody)
            [
              itemRefs[c.itemId],
              c.fromLocation,
              c.toLocation,
              c.reference,
              actor(c.byAuthUserId),
              c.at,
            ],
        ],
        _ => throw ArgumentError('Unknown export kind'),
      },
    );
  }
}
