import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/errors.dart';
import '../data/external_links.dart';

const exportKinds = {
  'items': 'Everything on the desk, including terminal items',
  'reports': 'Report and contact details',
  'matches': 'Proposals and staff decisions',
  'releases': 'Permanent release records',
  'custody': 'Moves and handovers',
};
bool canExport(StaffMembership membership) =>
    membership.role == StaffRole.supervisor;

class ExportSheet extends StatefulWidget {
  const ExportSheet({
    super.key,
    required this.export,
    this.open = openExternalLink,
  });
  final Future<ExportResult> Function(String kind) export;
  final Future<bool> Function(String url) open;
  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  String _kind = 'items';
  bool _busy = false;
  ExportResult? _result;
  Object? _error;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export CSV', style: Theme.of(context).textTheme.titleLarge),
          const Text(
            'Exports include staff-only records. Keep downloaded files private.',
          ),
          for (final kind in exportKinds.entries)
            ListTile(
              selected: _kind == kind.key,
              leading: Icon(
                _kind == kind.key
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(kind.key[0].toUpperCase() + kind.key.substring(1)),
              subtitle: Text(kind.value),
              onTap: _busy
                  ? null
                  : () => setState(() {
                      _kind = kind.key;
                      _result = null;
                      _error = null;
                    }),
            ),
          if (_error != null) Text(errorMessage(_error!)),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() {
                      _busy = true;
                      _error = null;
                    });
                    try {
                      final result = await widget.export(_kind);
                      if (mounted) setState(() => _result = result);
                    } catch (e) {
                      if (mounted) setState(() => _error = e);
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            child: Text(_busy ? 'Creating CSV…' : 'Create CSV'),
          ),
          if (_result case final result?) ...[
            const SizedBox(height: 16),
            Text('${result.rows} rows · Link valid for 10 minutes'),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await widget.open(result.url);
                } catch (e) {
                  if (mounted) setState(() => _error = e);
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Open CSV'),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: result.url));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Link copied.')));
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy download link'),
            ),
          ],
        ],
      ),
    ),
  );
}
