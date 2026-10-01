import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';

String? foundAfterText(FoundItem item, LostReport report) {
  if (report.lostAt == null) return null;
  final days = item.foundAt.difference(report.lostAt!).inDays;
  if (days == 0) return 'found on the lost day';
  return 'found ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'} ${days < 0 ? 'before' : 'after'} lost';
}

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
    final chips = <Widget>[];
    void add(
      String name,
      double? value, {
      String? detail,
      bool disagreement = false,
    }) {
      if (value == null || (value < .5 && !(value == 0 && disagreement))) {
        return;
      }
      final differs = value == 0;
      chips.add(
        Tooltip(
          message: '$name: ${value.toStringAsFixed(2)}',
          child: Chip(
            label: Text(differs ? '$name differs' : detail ?? name),
            backgroundColor: differs
                ? Colors.transparent
                : Theme.of(context).colorScheme.secondaryContainer,
            side: differs
                ? BorderSide(color: Theme.of(context).colorScheme.outline)
                : BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    add(
      'category',
      explanation.category,
      disagreement: true,
      detail: item?.attributes == null
          ? null
          : 'category: ${item!.attributes!.category}',
    );
    add(
      'colour',
      explanation.colour,
      detail: item?.attributes == null
          ? null
          : 'colour: ${item!.attributes!.colours.join(', ')}',
    );
    add(
      'brand',
      explanation.brand,
      disagreement: true,
      detail: item?.attributes?.brand == null
          ? null
          : 'brand: ${item!.attributes!.brand}',
    );
    add(
      'zone',
      explanation.zone,
      detail: zoneName == null ? null : 'zone: $zoneName',
    );
    add(
      'time',
      explanation.time,
      detail: item != null && report != null
          ? foundAfterText(item!, report!)
          : null,
    );
    if ((explanation.keywordCoverage ?? 0) >= .5) {
      for (final word in explanation.matchedKeywords.take(6)) {
        add('keyword', explanation.keywordCoverage, detail: 'keyword: $word');
      }
    }
    return Wrap(spacing: 6, runSpacing: 4, children: chips);
  }
}
