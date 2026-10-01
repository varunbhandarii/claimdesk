import 'package:claimdesk_client/claimdesk_client.dart';
import 'fixtures.dart';

MatchExplanation matchExplanation({
  double? category = 1,
  double? colour = 1,
  double? brand = 0,
  double? zone,
  double? time = 1,
  double? keyword = .8,
}) => MatchExplanation(
  category: category,
  colour: colour,
  brand: brand,
  zone: zone,
  time: time,
  keywordCoverage: keyword,
  matchedKeywords: ['wooden handle', 'black'],
  weightsHash: 'test',
);
MatchCard matchCard({bool restricted = false}) {
  final found = item(
    restricted: restricted,
  ).copyWith(captionText: 'Black bag with a patch');
  final report = LostReport(
    id: venueId,
    venueId: venueId,
    refCode: 'REPORT',
    publicToken: '',
    rawText: 'My black bag',
    colourHints: ['black'],
    lostAt: DateTime(2026, 9, 29, 10),
  );
  return MatchCard(
    item: found,
    report: report,
    clearLeader: true,
    match: ItemMatch(
      id: itemId,
      itemId: itemId,
      reportId: venueId,
      venueId: venueId,
      score: .82,
      label: 'strong',
      rank: 1,
      explanation: matchExplanation(),
      algorithmVersion: 'v1',
    ),
  );
}
