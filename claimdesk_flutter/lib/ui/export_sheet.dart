import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/errors.dart';
import '../data/external_links.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';

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
  Widget build(BuildContext context) {
    final c = context.desk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Export CSV', style: context.type.headingAt(22)),
            const SizedBox(height: 4),
            Text(
              'Exports include staff-only records. Keep downloaded files private.',
              style: context.type.body.copyWith(fontSize: 14, color: c.ink2),
            ),
            const SizedBox(height: 16),
            for (final kind in exportKinds.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  selected: _kind == kind.key,
                  inMutuallyExclusiveGroup: true,
                  child: DeskCard(
                    radius: 14,
                    selected: _kind == kind.key,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    onTap: _busy
                        ? null
                        : () => setState(() {
                            _kind = kind.key;
                            _result = null;
                            _error = null;
                          }),
                    child: Row(
                      children: [
                        Icon(
                          _kind == kind.key
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _kind == kind.key ? c.ink : c.ink3,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kind.key[0].toUpperCase() +
                                    kind.key.substring(1),
                                style: context.type.strong.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                kind.value,
                                style: context.type.small.copyWith(
                                  color: c.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  errorMessage(_error!),
                  style: TextStyle(color: c.bad),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
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
              icon: const Icon(Icons.table_view_outlined, size: 20),
              label: Text(_busy ? 'Creating CSV…' : 'Create CSV'),
            ),
            if (_result case final result?) ...[
              const SizedBox(height: 16),
              NoteStrip(
                icon: Icons.check_circle_outline,
                tone: DiscTone.ok,
                child: Text('${result.rows} rows · Link valid for 10 minutes'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await widget.open(result.url);
                  } catch (e) {
                    if (mounted) setState(() => _error = e);
                  }
                },
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Open CSV'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: result.url));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy download link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
