import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../screens/match_detail_screen.dart';
import 'status.dart';

class MatchList extends StatelessWidget {
  const MatchList({super.key, required this.cards});
  final List<MatchCard> cards;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (cards.isEmpty) const ListTile(title: Text('No candidates yet')),
      for (final card in cards)
        ListTile(
          leading: Icon(
            card.item.restricted ? Icons.lock_outline : Icons.compare_arrows,
          ),
          title: Text('${card.item.refCode} · ${card.report.refCode}'),
          subtitle: Text(
            '${matchStateLabel(card.match.state)} · ${card.match.label} · ${card.match.score.toStringAsFixed(2)}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openDeskScreen(
            context,
            VenueScope.of(context),
            MatchDetailScreen(
              matchId: card.match.id!,
              reportId: card.report.id!,
            ),
          ),
        ),
    ],
  );
}
