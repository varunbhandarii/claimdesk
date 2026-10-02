import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'candidate_query.dart';
import 'english_lexemes.dart';

/// Independent reference for candidate selection over small test inventories.
class InMemoryCandidates {
  InMemoryCandidates({DateTime Function()? now}) : now = now ?? DateTime.now;
  final DateTime Function() now;
  List<Candidate> forReport(
    LostReport report,
    List<FoundItem> items,
    List<Zone> zones,
  ) {
    final window = CandidateQuery.reportWindow(report, now());
    final filtered = items
        .where(
          (i) =>
              i.venueId == report.venueId &&
              i.status == ItemStatus.unclaimed &&
              !i.foundAt.isBefore(window.start) &&
              !i.foundAt.isAfter(window.end),
        )
        .toList();
    final query = EnglishLexemes.of(CandidateQuery.reportText(report));
    final vector = report.embedding == null
        ? <FoundItem>[]
        : (filtered.where((i) => i.embedding != null).toList()..sort((a, b) {
                final d = normalizedCosine(
                  report.embedding,
                  b.embedding,
                ).compareTo(normalizedCosine(report.embedding!, a.embedding!));
                return d == 0 ? a.id.toString().compareTo(b.id.toString()) : d;
              }))
              .take(25)
              .toList();
    final lexical =
        <({FoundItem item, double coverage, List<String> matched})>[];
    for (final item in filtered.where((i) => i.captionText != null)) {
      final matched = EnglishLexemes.of(
        item.captionText!,
      ).intersection(query).toList()..sort();
      if (matched.isNotEmpty) {
        lexical.add((
          item: item,
          coverage: matched.length / query.length,
          matched: matched,
        ));
      }
    }
    lexical.sort((a, b) {
      final d = b.coverage.compareTo(a.coverage);
      return d == 0 ? a.item.id.toString().compareTo(b.item.id.toString()) : d;
    });
    final lex = {for (final row in lexical.take(25)) row.item.id!: row};
    final byId = {for (final item in filtered) item.id!: item};
    final ids = {...vector.map((i) => i.id!), ...lex.keys};
    return [
      for (final id in ids)
        Candidate(
          report: report,
          item: byId[id]!,
          zones: zones,
          cosSim: cosine(report.embedding, byId[id]!.embedding),
          keywordCoverage: query.isEmpty ? null : lex[id]?.coverage ?? 0,
          matchedKeywords: lex[id]?.matched ?? [],
        ),
    ];
  }

  // pgvector orders by cosine distance, including the stored vector norms.
  // Unit vectors acquire small norm differences when stored as float32.
  static double normalizedCosine(Vector? query, Vector? document) {
    final a = query!.toList(), b = document!.toList();
    var dot = 0.0, aa = 0.0, bb = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      aa += a[i] * a[i];
      bb += b[i] * b[i];
    }
    return dot / sqrt(aa * bb);
  }

  /// Accepts only vector-only ties at the top-25 float32 distance boundary.
  /// SIMD accumulation differs slightly between database CPU architectures.
  bool selectionAgrees(
    LostReport report,
    List<FoundItem> items,
    List<Candidate> actual,
    List<Candidate> reference,
  ) {
    final actualIds = actual.map((c) => c.item.id).toSet();
    final referenceIds = reference.map((c) => c.item.id).toSet();
    if (actualIds.length == referenceIds.length &&
        actualIds.containsAll(referenceIds)) {
      return true;
    }
    if (actualIds.length != referenceIds.length || report.embedding == null) {
      return false;
    }
    final window = CandidateQuery.reportWindow(report, now());
    final eligible = items
        .where(
          (i) =>
              i.venueId == report.venueId &&
              i.status == ItemStatus.unclaimed &&
              i.embedding != null &&
              !i.foundAt.isBefore(window.start) &&
              !i.foundAt.isAfter(window.end),
        )
        .toList();
    if (eligible.length <= 25) return false;
    final similarities =
        eligible
            .map((i) => normalizedCosine(report.embedding, i.embedding))
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final cutoff = similarities[24];
    final eligibleIds = eligible.map((i) => i.id).toSet();
    final differing = [
      ...actual.where((c) => !referenceIds.contains(c.item.id)),
      ...reference.where((c) => !actualIds.contains(c.item.id)),
    ];
    return differing.every(
      (c) =>
          eligibleIds.contains(c.item.id) &&
          (c.keywordCoverage ?? 0) == 0 &&
          (normalizedCosine(report.embedding, c.item.embedding) - cutoff)
                  .abs() <=
              1e-6,
    );
  }
}
