import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_widgets.dart';
import 'format.dart';

String? foundAfterText(FoundItem item, LostReport report) {
  if (report.lostAt == null) return null;
  final days = item.foundAt.difference(report.lostAt!).inDays;
  if (days == 0) return 'found on the lost day';
  return 'found ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'} ${days < 0 ? 'before' : 'after'} lost';
}

/// The evidence behind a proposal, one line per signal that has something to
/// say. Low and missing signals are left out; explicit category or brand
/// disagreements are shown as differences.
class MatchChips extends StatelessWidget {
  const MatchChips({
    super.key,
    required this.explanation,
    this.item,
    this.report,
    this.zoneName,
  });
  final MatchExplanation explanation;
  final FoundItem? item;
  final LostReport? report;
  final String? zoneName;
  @override
  Widget build(BuildContext context) {
    final lines = <Widget>[];
    void add(
      String name,
      double? value,
      String text, {
      bool disagreement = false,
    }) {
      if (value == null || (value < .5 && !(value == 0 && disagreement))) {
        return;
      }
      final differs = value == 0;
      lines.add(
        Tooltip(
          message: '$name: ${value.toStringAsFixed(2)}',
          child: EvidenceLine(
            differs ? Evidence.differs : Evidence.agrees,
            differs ? '${capitalise(name)} differs' : text,
          ),
        ),
      );
    }

    final category = explanation.category;
    add(
      'category',
      category,
      category != null && category < 1 ? 'Similar category' : 'Category',
      disagreement: true,
    );
    add('colour', explanation.colour, 'Colour');
    add('brand', explanation.brand, 'Brand', disagreement: true);
    final zone = explanation.zone;
    add(
      'zone',
      zone,
      zone != null && zone < 1 ? 'Nearby zone' : 'Same zone',
    );
    final when = item != null && report != null
        ? foundAfterText(item!, report!)
        : null;
    add('time', explanation.time, when == null ? 'Time' : capitalise(when));
    if ((explanation.keywordCoverage ?? 0) >= .5) {
      for (final word in explanation.matchedKeywords.take(6)) {
        add('keyword', explanation.keywordCoverage, '“$word”');
      }
    }
    return Wrap(spacing: 14, runSpacing: 8, children: lines);
  }
}
