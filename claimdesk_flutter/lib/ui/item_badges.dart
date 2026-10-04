import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'format.dart';
import 'pills.dart';

/// Time-critical notices for an item on the shelf, most urgent first.
List<(String, Tone)> itemNotices(
  FoundItem item, {
  DateTime? now,
  bool compact = false,
}) {
  if (!{
    ItemStatus.unclaimed,
    ItemStatus.matched,
    ItemStatus.expired,
  }.contains(item.status)) {
    return const [];
  }
  final time = now ?? DateTime.now();
  final soon = time.add(const Duration(days: 3));
  final due = item.handoffDueAt, hold = item.holdUntil;
  return [
    if (due != null && due.isBefore(time))
      (compact ? 'Police overdue' : 'Police hand-off overdue', Tone.bad)
    else if (due != null && !due.isAfter(soon))
      (
        '${compact ? 'Police by' : 'Hand to police by'} ${shortDate(due, now: time)}',
        Tone.warn,
      ),
    if (hold != null && !hold.isBefore(time) && !hold.isAfter(soon))
      ('Hold ends ${shortDate(hold, now: time)}', Tone.warn),
  ];
}

class ItemBadges extends StatelessWidget {
  const ItemBadges({super.key, required this.item, this.now});
  final FoundItem item;
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    final notices = itemNotices(item, now: now);
    if (notices.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (text, tone) in notices) StatusPill(text, tone: tone),
      ],
    );
  }
}

/// Where the item is now, from its latest custody move.
class LocationLine extends StatelessWidget {
  const LocationLine({super.key, required this.events});
  final List<CustodyEvent> events;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final rows = [...events]
      ..sort((a, b) {
        final order = b.at.compareTo(a.at);
        return order != 0
            ? order
            : (b.id?.toString() ?? '').compareTo(a.id?.toString() ?? '');
      });
    final row = rows.firstOrNull;
    final (place, since) = switch (row?.toLocation) {
      null => ('At the desk', null),
      'safe' => ('In the safe', 'since ${shortDate(row!.at)}'),
      'police' => ('Handed to police', 'on ${shortDate(row!.at)}'),
      'issuer' => ('Handed to issuer', 'on ${shortDate(row!.at)}'),
      _ => ('At the desk', 'since ${shortDate(row!.at)}'),
    };
    return Semantics(
      container: true,
      label: 'Location',
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.place_outlined, size: 20, color: c.ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                row?.reference == null
                    ? place
                    : '$place · ref ${row!.reference}',
                style: context.type.strong.copyWith(fontSize: 15),
              ),
            ),
            if (since != null)
              Text(
                since,
                style: context.type.body.copyWith(fontSize: 13, color: c.ink3),
              ),
          ],
        ),
      ),
    );
  }
}
