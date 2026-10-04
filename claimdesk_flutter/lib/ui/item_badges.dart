import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';

class ItemBadges extends StatelessWidget {
  const ItemBadges({super.key, required this.item, this.now});
  final FoundItem item;
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    if (!{
      ItemStatus.unclaimed,
      ItemStatus.matched,
      ItemStatus.expired,
    }.contains(item.status)) {
      return const SizedBox.shrink();
    }
    final time = now ?? DateTime.now();
    final soon = time.add(const Duration(days: 3));
    final due = item.handoffDueAt, hold = item.holdUntil;
    String date(DateTime at) =>
        MaterialLocalizations.of(context).formatMediumDate(at.toLocal());
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (due != null && due.isBefore(time))
          Chip(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            label: const Text('Police hand-off overdue'),
          )
        else if (due != null && !due.isAfter(soon))
          Chip(
            backgroundColor: const Color(0xffffe6a3),
            label: Text('Hand to police by ${date(due)}'),
          ),
        if (hold != null && !hold.isBefore(time) && !hold.isAfter(soon))
          Chip(label: Text('Hold ends ${date(hold)}')),
      ],
    );
  }
}

class LocationLine extends StatelessWidget {
  const LocationLine({super.key, required this.events});
  final List<CustodyEvent> events;
  @override
  Widget build(BuildContext context) {
    final rows = [...events]
      ..sort((a, b) {
        final order = b.at.compareTo(a.at);
        return order != 0
            ? order
            : (b.id?.toString() ?? '').compareTo(a.id?.toString() ?? '');
      });
    if (rows.isEmpty) return const Text('Location: At the desk');
    final row = rows.first;
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(row.at.toLocal());
    final text = switch (row.toLocation) {
      'safe' => 'In the safe since $date',
      'police' => 'Handed to police on $date',
      'issuer' => 'Handed to issuer on $date',
      _ => 'At the desk since $date',
    };
    return Text(
      'Location: $text${row.reference == null ? "" : ", ref ${row.reference}"}',
    );
  }
}
