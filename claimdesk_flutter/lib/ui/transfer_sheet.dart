import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';

const _locations = [
  ('desk', 'Desk'),
  ('safe', 'Safe'),
  ('police', 'Police · leaves the venue'),
  ('issuer', 'Issuer · leaves the venue'),
];

class TransferSheet extends StatefulWidget {
  const TransferSheet({super.key});
  @override
  State<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<TransferSheet> {
  String _location = 'safe';
  final _reference = TextEditingController(), _note = TextEditingController();
  @override
  void dispose() {
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terminal = _location == 'police' || _location == 'issuer';
    final place = _locations.firstWhere((l) => l.$1 == _location).$2;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Transfer item', style: context.type.headingAt(22)),
            const SizedBox(height: 4),
            Text(
              'Record where the item goes. Every move stays in its history.',
              style: context.type.body.copyWith(
                fontSize: 14,
                color: context.desk.ink2,
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _location,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Location'),
              items: [
                for (final pair in _locations)
                  DropdownMenuItem(value: pair.$1, child: Text(pair.$2)),
              ],
              onChanged: (value) => setState(() => _location = value!),
            ),
            if (terminal) ...[
              const SizedBox(height: 12),
              const NoteStrip(
                icon: Icons.warning_amber_rounded,
                tone: DiscTone.warn,
                child: Text(
                  'This item leaves the venue. Pending matches will be rejected. A reserved item must have its confirmation undone first.',
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _reference,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Reference (optional)',
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Private note (optional)',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      terminal ? 'Hand this item over?' : 'Move this item?',
                    ),
                    content: Text(
                      terminal
                          ? 'The item will be marked Handed over and removed from the shelf.'
                          : 'Record the move to ${place.toLowerCase()}.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  Navigator.pop(
                    context,
                    TransferInput(
                      toLocation: _location,
                      reference: _reference.text.trim().isEmpty
                          ? null
                          : _reference.text.trim(),
                      note: _note.text.trim().isEmpty
                          ? null
                          : _note.text.trim(),
                    ),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisposeSheet extends StatefulWidget {
  const DisposeSheet({super.key, this.recommendedAction});
  final String? recommendedAction;
  @override
  State<DisposeSheet> createState() => _DisposeSheetState();
}

class _DisposeSheetState extends State<DisposeSheet> {
  static const actions = ['donate', 'recycle', 'destroy', 'discard'];
  late String _action = actions.contains(widget.recommendedAction)
      ? widget.recommendedAction!
      : 'donate';
  final _note = TextEditingController();
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Dispose expired item', style: context.type.headingAt(22)),
          if (widget.recommendedAction != null) ...[
            const SizedBox(height: 10),
            NoteStrip(
              icon: Icons.recommend_outlined,
              tone: DiscTone.tag,
              child: Text(
                'Recommended: ${disposalLabel(widget.recommendedAction!)}',
              ),
            ),
          ],
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _action,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Action'),
            items: [
              for (final action in actions)
                DropdownMenuItem(
                  value: action,
                  child: Text(capitalise(action)),
                ),
            ],
            onChanged: (v) => setState(() => _action = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Private note (optional)',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Mark this item disposed?'),
                  content: Text(
                    'Record “${capitalise(_action)}” and remove the item from the desk.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                Navigator.pop(
                  context,
                  DisposeInput(
                    action: _action,
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}
