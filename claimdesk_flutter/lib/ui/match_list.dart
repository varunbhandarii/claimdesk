import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../screens/match_detail_screen.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'pills.dart';
import 'status.dart';

/// Proposals for one record. On an item it lists the reports that may own
/// it; on a report it lists the items that may be the one.
class MatchList extends StatelessWidget {
  const MatchList({super.key, required this.cards, this.showReports = true});
  final List<MatchCard> cards;

  /// Show the report side of each pair (on item pages) rather than the item.
  final bool showReports;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    if (cards.isEmpty) {
      return Text('No candidates yet', style: TextStyle(color: c.ink3));
    }
    return Column(
      children: [
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DeskCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              onTap: () => openDeskScreen(
                context,
                VenueScope.of(context),
                MatchDetailScreen(
                  matchId: card.match.id!,
                  reportId: card.report.id!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            showReports
                                ? RefTicket(card.report.refCode)
                                : RefTag(card.item.refCode),
                            ScorePill(match: card.match),
                            if (card.match.state != MatchState.pending)
                              StatusPill(
                                matchStateLabel(card.match.state),
                                tone: matchStateTone(card.match.state),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showReports)
                          Text(
                            '“${reportLine(card.report)}”',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.body.copyWith(
                              fontSize: 13.5,
                              color: c.ink2,
                            ),
                          )
                        else
                          Row(
                            children: [
                              if (card.item.restricted) ...[
                                Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: c.ink2,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  card.item.restricted
                                      ? 'Restricted item'
                                      : itemTitle(card.item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.type.strong.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: c.ink3),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
