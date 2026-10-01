import 'dart:math';
import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import 'candidate_query.dart';
import 'match_chips_source.dart';
import 'match_weights.dart';

class ScoredCandidate {
  const ScoredCandidate({
    required this.candidate,
    required this.score,
    required this.label,
    required this.explanation,
  });
  final Candidate candidate;
  final double score;
  final String label;
  final MatchExplanation explanation;
}

class Scorer {
  const Scorer({this.weights = const MatchWeights()});
  static const algorithmVersion = 'v1';
  final MatchWeights weights;
  static String label(double score) => score >= .70
      ? 'strong'
      : score >= .45
      ? 'possible'
      : 'weak';

  ScoredCandidate score(Candidate c) {
    final report = c.report, item = c.item;
    final r = report.attributes, i = item.attributes;
    final reportCategory = r?.category ?? report.categoryHint ?? 'other';
    final itemCategory = i?.category ?? 'other';
    final category = reportCategory == 'other'
        ? null
        : reportCategory == itemCategory
        ? 1.0
        : Taxonomy.rollUp(reportCategory) == Taxonomy.rollUp(itemCategory)
        ? .5
        : 0.0;
    final colour = colourSignal(
      r?.colours ?? report.colourHints,
      i?.colours ?? [],
    );
    final brand = brandSignal(r?.brand ?? report.brandHint, i?.brand);
    final zone = zoneSignal(report.zoneId, item.zoneId, c.zones);
    final time = timeSignal(report, item);
    final sem = c.cosSim == null
        ? null
        : ((c.cosSim! - weights.semanticLow) /
                  (weights.semanticHigh - weights.semanticLow))
              .clamp(0.0, 1.0);
    final signals = [
      sem,
      c.keywordCoverage,
      category,
      colour,
      brand,
      zone,
      time,
    ];
    var numerator = 0.0, denominator = 0.0;
    for (var n = 0; n < signals.length; n++) {
      if (signals[n] != null) {
        numerator += signals[n]!.clamp(0.0, 1.0) * weights.values[n];
        denominator += weights.values[n];
      }
    }
    var value = denominator == 0 ? 0.0 : numerator / denominator;
    final guardrail = category == 0 && brand == 0;
    if (guardrail) value = min(value, .40);
    final explanation = MatchExplanation(
      cosSim: c.cosSim,
      keywordCoverage: c.keywordCoverage,
      matchedKeywords: displayKeywords(c.matchedKeywords, item),
      category: category,
      colour: colour,
      brand: brand,
      zone: zone,
      time: time,
      weightsHash: weights.hash,
      guardrailApplied: guardrail,
    );
    return ScoredCandidate(
      candidate: c,
      score: value.clamp(0.0, 1.0),
      label: label(value),
      explanation: explanation,
    );
  }

  static List<ScoredCandidate> kept(Iterable<ScoredCandidate> candidates) {
    final rows = candidates.toList()
      ..sort((a, b) {
        final comparison = b.score.compareTo(a.score);
        return comparison == 0
            ? a.candidate.item.id.toString().compareTo(
                b.candidate.item.id.toString(),
              )
            : comparison;
      });
    return [
      for (var n = 0; n < rows.length && n < 5; n++)
        if (n < 3 || rows[n].score >= .45) rows[n],
    ];
  }

  static bool clearLeader(double first, double? second) =>
      second == null || first - second >= .15 - 1e-12;
  static double? brandSignal(String? report, String? item) {
    String clean(String? text) =>
        (text ?? '').toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    final a = clean(report), b = clean(item);
    if (a.isEmpty || b.isEmpty || a == 'unknown' || b == 'unknown') return null;
    return a.contains(b) || b.contains(a) ? 1 : 0;
  }

  static double? colourSignal(List<String> report, List<String> item) {
    if (report.isEmpty || item.isEmpty) return null;
    const families = [
      {'navy', 'blue'},
      {'grey', 'silver'},
      {'beige', 'brown'},
    ];
    var sum = 0.0;
    for (final colour in report.toSet()) {
      sum += item.contains(colour)
          ? 1
          : families.any((f) => f.contains(colour) && item.any(f.contains))
          ? .5
          : 0;
    }
    return sum / report.toSet().length;
  }

  static double? zoneSignal(Object? report, Object? item, List<Zone> zones) {
    if (report == null) return null;
    if (report == item) return 1;
    if (zones.any(
      (z) =>
          (z.id == report && z.adjacentZoneIds.contains(item)) ||
          (z.id == item && z.adjacentZoneIds.contains(report)),
    )) {
      return .5;
    }
    return .25;
  }

  static double? timeSignal(LostReport report, FoundItem item) {
    if (report.lostAt == null) return null;
    final days =
        item.foundAt.difference(report.lostAt!).inMilliseconds /
        Duration.millisecondsPerDay;
    final fuzzy = report.lostAtFuzzyDays;
    if (days < -fuzzy) return .5;
    if (days <= 2 + fuzzy) return 1;
    return (1 - .8 * (days - 2 - fuzzy) / 43).clamp(.2, 1.0);
  }
}
