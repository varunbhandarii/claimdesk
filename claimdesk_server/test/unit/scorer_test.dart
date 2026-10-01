import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/matching/candidate_query.dart';
import 'package:claimdesk_server/src/matching/match_weights.dart';
import 'package:claimdesk_server/src/matching/scorer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

final id = UuidValue.fromString('12345678-1234-7123-8123-123456789abc');
final at = DateTime.utc(2026, 9, 30);
ItemAttributes attrs({
  String category = 'umbrella',
  List<String> colours = const ['black'],
  String? brand,
}) => ItemAttributes(
  category: category,
  colours: colours,
  brand: brand,
  marks: [],
  description: 'umbrella',
  containsPersonalData: false,
  personalDataKinds: [],
  keywords: [],
  source: 'fixture',
  modelId: 'fixture',
  promptVersion: 'fixture',
);
Candidate candidate({
  ItemAttributes? reportAttributes,
  ItemAttributes? itemAttributes,
  double? cosSim,
  double? lex,
  List<Zone> zones = const [],
  UuidValue? reportZone,
  UuidValue? itemZone,
  DateTime? lost,
  DateTime? found,
  int fuzzy = 0,
}) => Candidate(
  report: LostReport(
    venueId: id,
    refCode: 'REPORT',
    publicToken: '',
    rawText: '',
    colourHints: [],
    attributes: reportAttributes,
    zoneId: reportZone,
    lostAt: lost,
    lostAtFuzzyDays: fuzzy,
  ),
  item: FoundItem(
    id: id,
    venueId: id,
    refCode: 'ITEM',
    loggedByAuthUserId: id,
    attributes: itemAttributes,
    zoneId: itemZone,
    foundAt: found ?? at,
  ),
  zones: zones,
  cosSim: cosSim,
  keywordCoverage: lex,
  matchedKeywords: [],
);

void main() {
  const scorer = Scorer();
  test('semantic signal clamps at calibrated endpoints', () {
    for (final pair in [
      (-1.0, 0.0),
      (.25, 0.0),
      (.55, .5),
      (.85, 1.0),
      (1.0, 1.0),
    ]) {
      expect(
        scorer.score(candidate(cosSim: pair.$1)).score,
        closeTo(pair.$2, 1e-12),
      );
    }
    expect(scorer.score(candidate()).explanation.cosSim, isNull);
  });
  test(
    'lexical evidence and missing signals renormalise rather than penalise',
    () {
      expect(scorer.score(candidate(lex: .6)).score, closeTo(.6, 1e-12));
      expect(
        scorer.score(candidate(cosSim: .85, lex: 0)).score,
        closeTo(.4 / .55, 1e-12),
      );
      expect(scorer.score(candidate()).score, 0);
      expect(scorer.score(candidate()).explanation.keywordCoverage, isNull);
    },
  );
  test('category exact sibling different and unknown signals', () {
    for (final pair in [
      ('backpack', 1.0),
      ('handbag', .5),
      ('umbrella', 0.0),
    ]) {
      expect(
        scorer
            .score(
              candidate(
                reportAttributes: attrs(category: 'backpack'),
                itemAttributes: attrs(category: pair.$1),
              ),
            )
            .explanation
            .category,
        pair.$2,
      );
    }
    expect(
      scorer
          .score(
            candidate(
              reportAttributes: attrs(category: 'other'),
              itemAttributes: attrs(),
            ),
          )
          .explanation
          .category,
      isNull,
    );
  });
  test(
    'colour overlap divides by report colours and families contribute half',
    () {
      expect(Scorer.colourSignal(['black', 'red'], ['black']), .5);
      expect(Scorer.colourSignal(['navy'], ['blue']), .5);
      expect(Scorer.colourSignal(['grey'], ['silver']), .5);
      expect(Scorer.colourSignal(['beige'], ['brown']), .5);
      expect(Scorer.colourSignal(['black'], ['red']), 0);
      expect(Scorer.colourSignal([], ['black']), isNull);
      expect(Scorer.colourSignal(['black'], []), isNull);
    },
  );
  test(
    'brand ignores punctuation case and contains known brand but rejects disagreement',
    () {
      expect(Scorer.brandSignal('Hydro-Flask', 'Hydro Flask'), 1);
      expect(Scorer.brandSignal('Nike', 'Nike Sports'), 1);
      expect(Scorer.brandSignal('Nike', 'Adidas'), 0);
      expect(Scorer.brandSignal('unknown', 'Nike'), isNull);
      expect(Scorer.brandSignal(null, 'Nike'), isNull);
    },
  );
  test('zone adjacency is symmetric and missing report zone is null', () {
    final other = UuidValue.fromString('12345678-1234-7123-8123-123456789abd');
    final third = UuidValue.fromString('12345678-1234-7123-8123-123456789abe');
    final zones = [
      Zone(id: id, venueId: id, name: 'Desk', adjacentZoneIds: [other]),
    ];
    expect(Scorer.zoneSignal(id, id, zones), 1);
    expect(Scorer.zoneSignal(id, other, zones), .5);
    expect(Scorer.zoneSignal(other, id, zones), .5);
    expect(Scorer.zoneSignal(id, third, zones), .25);
    expect(Scorer.zoneSignal(null, id, zones), isNull);
  });
  test(
    'time peaks in fuzzy window decays to the edge and halves before loss',
    () {
      for (final pair in [(-1, .5), (0, 1.0), (2, 1.0), (45, .2)]) {
        final c = candidate(
          lost: at,
          found: at.add(Duration(days: pair.$1)),
        );
        expect(Scorer.timeSignal(c.report, c.item), closeTo(pair.$2, 1e-12));
      }
      for (final days in [-7, 9]) {
        final c = candidate(
          lost: at,
          found: at.add(Duration(days: days)),
          fuzzy: 7,
        );
        expect(Scorer.timeSignal(c.report, c.item), 1);
      }
      final middle = candidate(
        lost: at,
        found: at.add(const Duration(days: 23, hours: 12)),
      );
      expect(Scorer.timeSignal(middle.report, middle.item), closeTo(.6, 1e-12));
      final unknown = candidate();
      expect(Scorer.timeSignal(unknown.report, unknown.item), isNull);
    },
  );
  test(
    'two explicit category and brand disagreements cap even perfect retrieval',
    () {
      final result = scorer.score(
        candidate(
          reportAttributes: attrs(category: 'backpack', brand: 'Nike'),
          itemAttributes: attrs(category: 'umbrella', brand: 'Adidas'),
          cosSim: 1,
          lex: 1,
        ),
      );
      expect(result.score, .4);
      expect(result.label, 'weak');
      expect(result.explanation.guardrailApplied, isTrue);
    },
  );
  test('label thresholds include exact boundaries', () {
    expect(Scorer.label(.449999), 'weak');
    expect(Scorer.label(.45), 'possible');
    expect(Scorer.label(.699999), 'possible');
    expect(Scorer.label(.70), 'strong');
  });
  test(
    'kept set includes top three weak rows and further possible rows up to five',
    () {
      final c = candidate();
      ScoredCandidate row(double n) => ScoredCandidate(
        candidate: c,
        score: n,
        label: Scorer.label(n),
        explanation: scorer.score(c).explanation,
      );
      expect(Scorer.kept([.1, .2, .3, .4].map(row)).map((r) => r.score), [
        .4,
        .3,
        .2,
      ]);
      expect(
        Scorer.kept([.1, .45, .5, .6, .7, .8, .9].map(row)).map((r) => r.score),
        [.9, .8, .7, .6, .5],
      );
    },
  );
  test('hash is stable and changes with semantic constants', () {
    expect(const MatchWeights().hash, const MatchWeights().hash);
    expect(const MatchWeights().hash, matches(RegExp('^[0-9a-f]{8}\$')));
    expect(
      const MatchWeights(semanticLow: .3).hash,
      isNot(const MatchWeights().hash),
    );
  });
  test('clear leader includes exact fifteen-point margin', () {
    expect(Scorer.clearLeader(.8, .65), isTrue);
    expect(Scorer.clearLeader(.8, .650001), isFalse);
    expect(Scorer.clearLeader(.8, null), isTrue);
  });
}
