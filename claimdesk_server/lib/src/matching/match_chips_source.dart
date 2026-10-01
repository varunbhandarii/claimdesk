import '../generated/protocol.dart';
import 'english_lexemes.dart';

/// Map PostgreSQL English lexemes back to readable caption words and marks.
List<String> displayKeywords(List<String> lexemes, FoundItem item) {
  final words = RegExp(r'[a-z]+(?:-[a-z]+)?')
      .allMatches((item.captionText ?? '').toLowerCase())
      .map((m) => m.group(0)!)
      .toList();
  bool matches(String word) => lexemes.contains(EnglishLexemes.stem(word));
  final result = <String>[];
  final used = <String>{};
  for (final mark in item.attributes?.marks ?? <String>[]) {
    final parts = RegExp(
      r'[a-z]+',
    ).allMatches(mark.toLowerCase()).map((m) => m.group(0)!).toList();
    if (parts.length >= 2 && parts.every(matches)) {
      result.add(mark.toLowerCase());
      used.addAll(parts);
    }
  }
  for (final word in words) {
    if (matches(word) && !used.contains(word)) {
      result.add(word);
      used.add(word);
    }
  }
  return result.toSet().take(6).toList();
}

typedef ExplanationChip = ({String text, double value, bool differs});
List<ExplanationChip> explanationChips(MatchExplanation e) {
  final chips = <ExplanationChip>[];
  void add(String name, double? value, {bool disagreement = false}) {
    if (value == null) return;
    if (value >= .5 || (value == 0 && disagreement)) {
      chips.add((
        text: value == 0 ? '$name differs' : name,
        value: value,
        differs: value == 0,
      ));
    }
  }

  add('category', e.category, disagreement: true);
  add('colour', e.colour);
  add('brand', e.brand, disagreement: true);
  add('zone', e.zone);
  add('time', e.time);
  if ((e.keywordCoverage ?? 0) >= .5) {
    for (final keyword in e.matchedKeywords.take(6)) {
      chips.add((
        text: 'keyword: $keyword',
        value: e.keywordCoverage!,
        differs: false,
      ));
    }
  }
  return chips;
}
