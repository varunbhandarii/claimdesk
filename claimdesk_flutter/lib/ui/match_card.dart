import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'match_chips.dart';
import 'pills.dart';

bool isPreliminary(ItemMatch match) =>
    match.algorithmVersion.endsWith('-draft');

/// "Front desk · lost around Sep 30, day uncertain".
String lostMeta(LostReport report, String? zoneName, {DateTime? now}) {
  final parts = <String>[?zoneName];
  if (report.lostAt != null) {
    final day = shortDate(report.lostAt!, now: now);
    parts.add(
      report.lostAtFuzzyDays > 0
          ? 'lost around $day, day uncertain'
          : 'lost $day',
    );
  } else {
    parts.add('filed ${timeAgo(report.createdAt, now: now)}');
  }
  return parts.join(' · ');
}

/// A proposal drawn as a claim ticket: the found half on top, the lost half
/// below, joined at a perforation that carries the score.
class MatchCardTile extends StatelessWidget {
  const MatchCardTile({
    super.key,
    required this.card,
    this.photo,
    this.actions,
    this.zoneName,
    this.reportZoneName,
    this.onTap,
    this.now,
  });
  final MatchCard card;
  final Widget? photo, actions;
  final String? zoneName, reportZoneName;
  final VoidCallback? onTap;
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final item = card.item, report = card.report, match = card.match;
    final small = context.type.small.copyWith(color: c.ink3);
    return DeskCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                PhotoThumb(photo: photo, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RefTag(item.refCode),
                          const Spacer(),
                          const DeskLabel('Found'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (item.restricted)
                        Row(
                          children: [
                            Icon(Icons.lock_outline, size: 17, color: c.ink2),
                            const SizedBox(width: 5),
                            Text(
                              'Restricted item',
                              style: context.type.strong.copyWith(fontSize: 15),
                            ),
                          ],
                        )
                      else
                        Text(
                          itemTitle(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.strong.copyWith(fontSize: 15),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          ?zoneName,
                          'found ${shortDate(item.foundAt, now: now)}',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Seam(
            child: Wrap(
              spacing: 6,
              children: [
                ScorePill(match: match),
                if (isPreliminary(match))
                  const StatusPill('Preliminary', tone: Tone.draft),
                if (card.clearLeader)
                  const StatusPill(
                    'Clear leader',
                    tone: Tone.tag,
                    icon: Icons.star_outline,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RefTicket(report.refCode),
                    const Spacer(),
                    const DeskLabel('Lost'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '“${reportLine(report)}”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.body.copyWith(
                    fontSize: 14,
                    color: c.ink2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(lostMeta(report, reportZoneName, now: now), style: small),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
            child: MatchChips(
              explanation: match.explanation,
              item: item,
              report: report,
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: actions!,
            ),
        ],
      ),
    );
  }
}

/// One-line proposal: thumbnail, the joined codes, a short name and the score.
class MatchRow extends StatelessWidget {
  const MatchRow({
    super.key,
    required this.card,
    this.photo,
    this.onTap,
    this.showChevron = false,
    this.detail,
  });
  final MatchCard card;
  final Widget? photo;
  final VoidCallback? onTap;
  final bool showChevron;
  final String? detail;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final keyword = card.match.explanation.matchedKeywords.firstOrNull;
    final title = card.item.restricted
        ? 'Restricted item'
        : itemTitle(card.item);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PhotoThumb(photo: photo, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ClaimPair(
                      item: card.item.refCode,
                      report: card.report.refCode,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: context.type.strong.copyWith(color: c.ink),
                        ),
                        if ((detail ?? keyword) != null)
                          TextSpan(text: ' · ${detail ?? keyword}'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.body.copyWith(
                      fontSize: 13.5,
                      color: c.ink3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ScorePill(match: card.match, withLabel: false),
                if (isPreliminary(card.match)) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Preliminary',
                    style: context.type.strong.copyWith(
                      fontSize: 11.5,
                      color: c.ink3,
                    ),
                  ),
                ],
              ],
            ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: c.ink3),
            ],
          ],
        ),
      ),
    );
  }
}
