import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'status.dart';

/// Readable name for a stored item, report or match state.
String stateLabel(String raw) {
  for (final status in ItemStatus.values) {
    if (status.name == raw) return statusLabel(status);
  }
  for (final status in ReportStatus.values) {
    if (status.name == raw) return reportStatusLabel(status);
  }
  for (final state in MatchState.values) {
    if (state.name == raw) return matchStateLabel(state);
  }
  return capitalise(raw.replaceAll('_', ' '));
}

class HistoryList extends StatefulWidget {
  const HistoryList({super.key, required this.entries, this.now});
  final List<HistoryEntry> entries;
  final DateTime? now;
  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  bool _all = false;
  @override
  Widget build(BuildContext context) {
    final rows = [...widget.entries]..sort((a, b) => b.at.compareTo(a.at));
    final visible = _all ? rows : rows.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          'History',
          trailing: rows.length > 3
              ? TextButton(
                  onPressed: () => setState(() => _all = !_all),
                  child: Text(_all ? 'Show recent' : 'Show all ${rows.length}'),
                )
              : null,
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Text(
            'No history yet',
            style: TextStyle(color: context.desk.ink3),
          ),
        for (var i = 0; i < visible.length; i++)
          _HistoryRow(
            entry: visible[i],
            last: i == visible.length - 1,
            now: widget.now,
          ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.last, this.now});
  final HistoryEntry entry;
  final bool last;
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (icon, tone) = switch (entry.kind) {
      'custody' => (Icons.swap_horiz, DiscTone.mute),
      'release' => (Icons.check, DiscTone.ok),
      'caption' => (Icons.auto_awesome_outlined, DiscTone.mute),
      'match' => (Icons.link, DiscTone.info),
      'report' => (Icons.confirmation_number_outlined, DiscTone.info),
      _ => (Icons.history, DiscTone.mute),
    };
    final small = context.type.small.copyWith(color: c.ink3);
    return Stack(
      children: [
        if (!last)
          Positioned(
            left: 13,
            top: 30,
            bottom: 4,
            child: Container(width: 2, color: c.line),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 14),
              child: IconDisc(icon, tone: tone, size: 24, iconSize: 14),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: last ? 4 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.summary,
                      style: context.type.strong.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.actor} · ${timeAgo(entry.at, now: now)}',
                      style: small,
                    ),
                    if (entry.fromState != null || entry.toState != null)
                      Text(
                        '${entry.fromState == null ? '—' : stateLabel(entry.fromState!)} → ${entry.toState == null ? '—' : stateLabel(entry.toState!)}',
                        style: small,
                      ),
                    if (entry.counterpart != null)
                      Text(
                        'Reference ${entry.counterpart}',
                        style: context.type.mono.copyWith(
                          fontSize: 12.5,
                          color: c.ink2,
                        ),
                      ),
                    if (entry.data.isNotEmpty)
                      ExpansionTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        minTileHeight: 36,
                        title: Text(
                          'Show details',
                          style: context.type.strong.copyWith(fontSize: 13.5),
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final data in entry.data.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DeskLabel(
                                    data.key.replaceAllMapped(
                                      RegExp('([a-z])([A-Z])'),
                                      (m) => '${m[1]} ${m[2]}',
                                    ),
                                  ),
                                  SelectableText(data.value),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
