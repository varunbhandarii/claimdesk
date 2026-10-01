import 'dart:typed_data';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/owner_answers.dart';
import '../ui/release_rules.dart';

class ReleaseScreen extends StatefulWidget {
  const ReleaseScreen({
    super.key,
    required this.item,
    this.matchId,
    this.reportRefCode,
    this.answers = const [],
    this.submit,
  });
  final FoundItem item;
  final UuidValue? matchId;
  final String? reportRefCode;
  final List<ReportAnswer> answers;
  final Future<ReleaseSummary> Function(ReleaseInput, ByteData?)? submit;
  @override
  State<ReleaseScreen> createState() => _ReleaseScreenState();
}

class _ReleaseScreenState extends State<ReleaseScreen> {
  final _name = TextEditingController(), _note = TextEditingController();
  final _signature = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _described = false, _thirdParty = false, _busy = false;
  int _details = 0;
  String? _idType;
  ReleaseInput get _input => ReleaseInput(
    matchId: widget.matchId,
    claimantName: _name.text,
    idTypeSeen: _idType ?? '',
    detailsMatched: _details,
    describedBeforeViewing: _described,
    thirdParty: _thirdParty,
    thirdPartyAuthorisationNote: _thirdParty ? _note.text : null,
  );
  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _signature.dispose();
    super.dispose();
  }

  Future<void> _return() async {
    final s = widget.submit == null ? VenueScope.of(context) : null;
    setState(() => _busy = true);
    final result = await runGuarded(context, () async {
      final bytes = _signature.isNotEmpty
          ? await _signature.toPngBytes()
          : null;
      final data = bytes == null ? null : ByteData.sublistView(bytes);
      return widget.submit != null
          ? widget.submit!(_input, data)
          : s!.client.release.release(widget.item.id!, _input, data);
    }, onDenied: s?.onDenied);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == null) return;
    s?.scheduleRefresh();
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Item returned'),
        content: Text(
          'Item ${widget.item.refCode}${result.reportRefCode == null ? '' : '\nReport ${result.reportRefCode}'}\n${result.record.releasedAt.toLocal().toString().split('.').first}\nID type seen: ${ReleaseRules.labels[result.record.idTypeSeen]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Return item')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Item ${widget.item.refCode}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (widget.item.captionText != null) Text(widget.item.captionText!),
            Text(
              widget.reportRefCode == null
                  ? 'Walk-in, no report'
                  : 'Report ${widget.reportRefCode}',
            ),
            if (widget.matchId != null) OwnerAnswers(answers: widget.answers),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Claimant described the item before seeing it'),
              value: _described,
              onChanged: _busy ? null : (v) => setState(() => _described = v),
            ),
            const Text('Owner-only details matched'),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Fewer details',
                  onPressed: _busy || _details == 0
                      ? null
                      : () => setState(() => _details--),
                  icon: const Icon(Icons.remove),
                ),
                Text('$_details', key: const Key('details-count')),
                IconButton(
                  tooltip: 'More details',
                  onPressed: _busy || _details == 5
                      ? null
                      : () => setState(() => _details++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Text(
              'At least ${ReleaseRules.minimum(widget.item)} required for this item. Phones, wallets, IDs, keys, jewellery and high-value items require two.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _idType,
              decoration: const InputDecoration(labelText: 'Photo ID seen'),
              items: [
                for (final e in ReleaseRules.labels.entries)
                  if (e.key != 'none' || ReleaseRules.allowsNoId(widget.item))
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: _busy ? null : (v) => setState(() => _idType = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              enabled: !_busy,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Claimant name'),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Collected by someone else'),
              value: _thirdParty,
              onChanged: _busy ? null : (v) => setState(() => _thirdParty = v),
            ),
            if (_thirdParty)
              TextField(
                controller: _note,
                enabled: !_busy,
                maxLength: 300,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Authorisation note',
                  helperText:
                      'Record how the owner authorised this collector; do not enter ID numbers.',
                ),
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 16),
            const Text('Signature (optional)'),
            Semantics(
              label: 'Draw optional signature',
              child: AbsorbPointer(
                absorbing: _busy,
                child: Signature(
                  key: const Key('release-signature'),
                  controller: _signature,
                  height: 160,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _signature.clear,
              child: const Text('Clear signature'),
            ),
            FilledButton(
              onPressed: _busy || !ReleaseRules.valid(widget.item, _input)
                  ? null
                  : _return,
              child: Text(_busy ? 'Returning…' : 'Returned'),
            ),
          ],
        ),
      ),
    ),
  );
}
