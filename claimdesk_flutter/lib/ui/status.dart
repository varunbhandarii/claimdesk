import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'pills.dart';

String matchStateLabel(MatchState state) => switch (state) {
  MatchState.pending => 'Proposed',
  MatchState.confirmed => 'Confirmed',
  MatchState.rejected => 'Dismissed',
  MatchState.superseded => 'Superseded',
};

Tone matchStateTone(MatchState state) => switch (state) {
  MatchState.pending => Tone.tag,
  MatchState.confirmed => Tone.ok,
  MatchState.rejected || MatchState.superseded => Tone.mute,
};

class MatchingUnavailable extends StatelessWidget {
  const MatchingUnavailable({super.key});
  @override
  Widget build(BuildContext context) => const StatusPill(
    'Matching unavailable',
    tone: Tone.warn,
    icon: Icons.warning_amber_rounded,
  );
}

String reportStatusLabel(ReportStatus status) => switch (status) {
  ReportStatus.received => 'Received',
  ReportStatus.searching => 'Searching',
  ReportStatus.possibleMatch => 'Possible match',
  ReportStatus.readyForPickup => 'Ready for pickup',
  ReportStatus.returned => 'Returned',
  ReportStatus.closed => 'Closed',
};

class ReportStatusChip extends StatelessWidget {
  const ReportStatusChip(this.status, {super.key});
  final ReportStatus status;
  @override
  Widget build(BuildContext context) =>
      StatusPill(reportStatusLabel(status), tone: reportTone(status));
}

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

/// Text colour of an item status pill on the light theme.
Color statusColour(ItemStatus status) =>
    StatusPill.colours(DeskColors.light, itemTone(status)).$2;

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final ItemStatus status;
  @override
  Widget build(BuildContext context) =>
      StatusPill(statusLabel(status), tone: itemTone(status));
}
