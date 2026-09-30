import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';

String statusLabel(ItemStatus status) => switch (status) {
  ItemStatus.intake => 'Logged',
  ItemStatus.captioning => 'Captioning',
  ItemStatus.unclaimed => 'On shelf',
  ItemStatus.matched => 'Match proposed',
  ItemStatus.claimed => 'Returned',
  ItemStatus.transferred => 'Handed over',
  ItemStatus.disposed => 'Disposed',
  ItemStatus.expired => 'Expired',
};
Color statusColour(ItemStatus status) => switch (status) {
  ItemStatus.captioning || ItemStatus.intake => const Color(0xff785100),
  ItemStatus.unclaimed => const Color(0xff17624a),
  ItemStatus.matched => const Color(0xff3c5090),
  _ => const Color(0xff52565b),
};

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final ItemStatus status;
  @override
  Widget build(BuildContext context) {
    final colour = statusColour(status);
    return Chip(
      label: Text(statusLabel(status), style: TextStyle(color: colour)),
      backgroundColor: Color.alphaBlend(
        colour.withValues(alpha: .09),
        Colors.white,
      ),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
