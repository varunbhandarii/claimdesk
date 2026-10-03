import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'item_card.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key, required this.entries});
  final List<HistoryEntry> entries;
  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  bool _all = false;
  @override
  Widget build(BuildContext context) {
    final rows = [...widget.entries]..sort((a, b) => b.at.compareTo(a.at));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: Theme.of(context).textTheme.titleLarge),
        if (rows.isEmpty) const ListTile(title: Text('No history yet')),
        for (final row in (_all ? rows : rows.take(3)))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 12),
                  child: Icon(switch (row.kind) {
                    'custody' => Icons.move_to_inbox_outlined,
                    'release' => Icons.handshake_outlined,
                    'caption' => Icons.auto_awesome_outlined,
                    _ => Icons.history,
                  }),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.summary),
                      Text(
                        '${row.actor} · ${timeAgo(row.at)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (row.fromState != null || row.toState != null)
                        Text('${row.fromState ?? "—"} → ${row.toState ?? "—"}'),
                      if (row.counterpart != null)
                        Text('Reference ${row.counterpart}'),
                      if (row.data.isNotEmpty)
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Show details'),
                          children: [
                            for (final data in row.data.entries)
                              ListTile(
                                dense: true,
                                title: Text(data.key),
                                subtitle: SelectableText(data.value),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (rows.length > 3)
          TextButton(
            onPressed: () => setState(() => _all = !_all),
            child: Text(_all ? 'Show recent' : 'Show all (${rows.length})'),
          ),
      ],
    );
  }
}
