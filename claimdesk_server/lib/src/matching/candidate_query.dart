import 'package:serverpod/serverpod.dart';
import '../ai/text_template.dart';
import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import 'apply_profile.dart';
import 'lexical_search.dart';

typedef MatchWindow = ({DateTime start, DateTime end});

class Candidate {
  const Candidate({
    required this.report,
    required this.item,
    required this.zones,
    required this.cosSim,
    required this.keywordCoverage,
    required this.matchedKeywords,
  });
  final LostReport report;
  final FoundItem item;
  final List<Zone> zones;
  final double? cosSim, keywordCoverage;
  final List<String> matchedKeywords;
}

double? cosine(Vector? a, Vector? b) {
  if (a == null || b == null) return null;
  final x = a.toList(), y = b.toList();
  if (x.length != y.length || x.isEmpty) return null;
  var dot = 0.0;
  for (var i = 0; i < x.length; i++) {
    dot += x[i] * y[i];
  }
  return dot.clamp(-1.0, 1.0);
}

class CandidateQuery {
  CandidateQuery({DateTime Function()? now}) : now = now ?? DateTime.now;
  final DateTime Function() now;
  static const openReports = {
    ReportStatus.received,
    ReportStatus.searching,
    ReportStatus.possibleMatch,
  };
  static MatchWindow reportWindow(LostReport r, DateTime now) {
    final lost = r.lostAt;
    return lost == null
        ? (start: r.createdAt.subtract(const Duration(days: 60)), end: now)
        : (
            start: lost.subtract(Duration(days: 2 + r.lostAtFuzzyDays)),
            end: lost.add(Duration(days: 45 + r.lostAtFuzzyDays)),
          );
  }

  static String reportText(LostReport r) => Taxonomy.canonicalize(
    [
      if (r.attributes != null) TextTemplate.render(r.attributes!),
      // Restricted records must not search personal details from the raw report.
      if (r.attributes == null || !restrictedAttributes(r.attributes!))
        r.rawText,
      ...?r.attributes?.keywords,
    ].join(' '),
  );

  Future<List<Candidate>> forReport(
    Session s,
    LostReport report, {
    ApplyProfile? profile,
    List<Zone>? zones,
  }) async {
    Future<T> measured<T>(Future<T> Function() query) =>
        profile == null ? query() : profile.candidate(query);
    final window = reportWindow(report, now());
    final vector = report.embedding == null
        ? <FoundItem>[]
        : await measured(
            () => FoundItem.db.find(
              s,
              where: (t) =>
                  t.venueId.equals(report.venueId) &
                  t.status.equals(ItemStatus.unclaimed) &
                  Expression('${t.embedding} IS NOT NULL') &
                  t.foundAt.between(window.start, window.end),
              orderByList: (t) => [
                t.embedding.distanceCosine(Vector(report.embedding!.toList())),
                t.id,
              ],
              limit: 25,
            ),
          );
    final lex = await measured(
      () => _lexical(
        s,
        table: 'found_item',
        document: 'f."captionText"',
        filter: '''f."status" = 'unclaimed'
        AND f."captionText" IS NOT NULL AND f."foundAt" BETWEEN @lo AND @hi''',
        text: reportText(report),
        venueId: report.venueId,
        window: window,
      ),
    );
    final ids = {...vector.map((i) => i.id!), ...lex.rows.keys};
    if (ids.isEmpty) return [];
    final items = await measured(
      () => FoundItem.db.find(
        s,
        where: (t) =>
            t.id.inSet(ids) &
            t.venueId.equals(report.venueId) &
            t.status.equals(ItemStatus.unclaimed) &
            t.foundAt.between(window.start, window.end),
      ),
    );
    final List<Zone> venueZones =
        zones ??
        await measured<List<Zone>>(
          () => Zone.db.find(
            s,
            where: (t) => t.venueId.equals(report.venueId),
          ),
        );
    final byId = {for (final item in items) item.id!: item};
    return [
      for (final id in ids)
        if (byId[id] case final item?)
          Candidate(
            report: report,
            item: item,
            zones: venueZones,
            cosSim: cosine(report.embedding, item.embedding),
            keywordCoverage: lex.total == 0
                ? null
                : lex.rows[id]?.coverage ?? 0,
            matchedKeywords: lex.rows[id]?.matched ?? [],
          ),
    ];
  }

  Future<List<Candidate>> forItem(Session s, FoundItem item) async {
    final window = (
      start: item.foundAt.subtract(const Duration(days: 52)),
      end: item.foundAt.add(const Duration(days: 9)),
    );
    final earliestCreated = item.foundAt.subtract(const Duration(days: 60));
    final vector = item.embedding == null
        ? <LostReport>[]
        : await LostReport.db.find(
            s,
            where: (t) =>
                t.venueId.equals(item.venueId) &
                t.status.inSet(openReports) &
                Expression('${t.embedding} IS NOT NULL') &
                (t.lostAt.between(window.start, window.end) |
                    (t.lostAt.equals(null) & (t.createdAt >= earliestCreated))),
            orderByList: (t) => [
              t.embedding.distanceCosine(Vector(item.embedding!.toList())),
              t.id,
            ],
            limit: 25,
          );
    final lex = await _lexical(
      s,
      table: 'lost_report',
      document:
          '''CASE WHEN coalesce((f."attributes"->>'containsPersonalData')::boolean, false)
        OR coalesce(f."attributes"->>'category', '') IN ('wallet_or_purse','bank_card','cash','id_card_or_pass','medical_device_or_medication','jewellery')
        THEN coalesce(f."attributes"->>'description', '')
        ELSE f."rawText" || ' ' || coalesce(f."attributes"->>'description', '') END''',
      filter: '''f."status" IN ('received','searching','possibleMatch') AND
        (f."lostAt" BETWEEN @lo AND @hi OR
        (f."lostAt" IS NULL AND f."createdAt" >= @created))''',
      text: Taxonomy.canonicalize(item.captionText ?? ''),
      venueId: item.venueId,
      window: window,
      earliestCreated: earliestCreated,
    );
    final ids = {...vector.map((r) => r.id!), ...lex.rows.keys};
    if (ids.isEmpty) return [];
    final reports = await LostReport.db.find(
      s,
      where: (t) =>
          t.id.inSet(ids) &
          t.venueId.equals(item.venueId) &
          t.status.inSet(openReports) &
          (t.lostAt.between(window.start, window.end) |
              (t.lostAt.equals(null) & (t.createdAt >= earliestCreated))),
    );
    final zones = await Zone.db.find(
      s,
      where: (t) => t.venueId.equals(item.venueId),
    );
    final byId = {for (final r in reports) r.id!: r};
    return [
      for (final id in ids)
        if (byId[id] case final report?)
          Candidate(
            report: report,
            item: item,
            zones: zones,
            cosSim: cosine(report.embedding, item.embedding),
            keywordCoverage: lex.total == 0
                ? null
                : lex.rows[id]?.coverage ?? 0,
            matchedKeywords: lex.rows[id]?.matched ?? [],
          ),
    ];
  }

  Future<LexicalResult> _lexical(
    Session s, {
    required String table,
    required String document,
    required String filter,
    required String text,
    required UuidValue venueId,
    required MatchWindow window,
    DateTime? earliestCreated,
  }) => LexicalSearch.query(
    s,
    table: table,
    document: document,
    filter: filter,
    text: text,
    venueId: venueId,
    parameters: {
      'lo': window.start,
      'hi': window.end,
      'created': ?earliestCreated,
    },
  );
}
