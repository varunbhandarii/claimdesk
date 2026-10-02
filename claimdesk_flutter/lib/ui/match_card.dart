import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'match_chips.dart';

class MatchCardTile extends StatelessWidget {
  const MatchCardTile({
    super.key,
    required this.card,
    this.photo,
    this.actions,
    this.zoneName,
    this.onTap,
  });
  final MatchCard card;
  final Widget? photo, actions;
  final String? zoneName;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final strong = card.match.label == 'strong';
    final colour = strong ? const Color(0xff17624a) : const Color(0xff785100);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          photo ??
                          const ColoredBox(
                            color: Color(0xffeceff0),
                            child: Icon(Icons.image_outlined, size: 32),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.item.refCode,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (card.item.restricted)
                          const Row(
                            children: [
                              Icon(Icons.lock_outline, size: 18),
                              SizedBox(width: 4),
                              Text('Restricted item'),
                            ],
                          )
                        else
                          Text(
                            (card.item.captionText ?? 'Item details pending')
                                .split('\n')
                                .first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Report ${card.report.refCode}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          card.report.rawText.split('\n').first,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (card.match.algorithmVersion.endsWith('-draft'))
                    const Chip(
                      label: Text('Preliminary'),
                      side: BorderSide(color: Color(0xff6b7280)),
                      backgroundColor: Colors.transparent,
                    ),
                  Chip(
                    label: Text(
                      '${strong ? 'Strong' : 'Possible'} · ${card.match.score.toStringAsFixed(2)}',
                      style: TextStyle(color: colour),
                    ),
                    backgroundColor: colour.withValues(alpha: .09),
                    side: BorderSide.none,
                  ),
                  if (card.clearLeader)
                    const Chip(
                      avatar: Icon(Icons.star_outline, size: 18),
                      label: Text('Clear leader'),
                    ),
                ],
              ),
              MatchChips(
                explanation: card.match.explanation,
                item: card.item,
                report: card.report,
                zoneName: zoneName,
              ),
              if (actions != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: actions!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
