import 'dart:typed_data';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_chip.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/format.dart';
import '../ui/owner_answers.dart';
import '../ui/pills.dart';
import '../ui/release_rules.dart';

class ReleaseScreen extends StatefulWidget {
  const ReleaseScreen({
    super.key,
    required this.item,
    this.matchId,
    this.reportRefCode,
    this.answers = const [],
    this.submit,
    this.photo,
  });
  final FoundItem item;
  final UuidValue? matchId;
  final String? reportRefCode;
  final List<ReportAnswer> answers;
  final Future<ReleaseSummary> Function(ReleaseInput, ByteData?)? submit;
  final Widget? photo;
  @override
  State<ReleaseScreen> createState() => _ReleaseScreenState();
}

class _ReleaseScreenState extends State<ReleaseScreen> {
  final _name = TextEditingController(), _note = TextEditingController();
  final _signature = SignatureController(
    penStrokeWidth: 2.6,
    penColor: const Color(0xFF16181B),
    exportBackgroundColor: const Color(0xFFFFFFFF),
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
        icon: const IconDisc(Icons.check, tone: DiscTone.ok, size: 48),
        title: const Text('Item returned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                RefTag(widget.item.refCode),
                if (result.reportRefCode != null)
                  RefTicket(result.reportRefCode!),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${dateTimeLabel(result.record.releasedAt)}\nID type seen: ${ReleaseRules.labels[result.record.idTypeSeen]}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final item = widget.item;
    final minimum = ReleaseRules.minimum(item);
    final name = ReleaseRules.clean(_name.text);
    final note = ReleaseRules.clean(_note.text);
    final checks = [
      _described,
      _details >= minimum,
      _idType != null &&
          ReleaseRules.labels.containsKey(_idType) &&
          (_idType != 'none' || ReleaseRules.allowsNoId(item)),
      name.length >= 2 &&
          name.length <= 120 &&
          (!_thirdParty || (note.length >= 5 && note.length <= 300)),
    ];
    final done = checks.where((ok) => ok).length;
    final valid = ReleaseRules.valid(item, _input);
    Widget section(int number, String title, {Widget? trailing}) => Row(
      children: [
        StepNumber(number),
        const SizedBox(width: 10),
        Text(title, style: context.type.headingAt(19)),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
    const gap = SizedBox(height: 22);
    return Scaffold(
      appBar: AppBar(title: const Text('Return to owner')),
      body: LayoutBuilder(
        builder: (context, box) => ListView(
          padding: EdgeInsets.fromLTRB(
            box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
            4,
            box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
            32,
          ),
          children: [
            DeskCard(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              child: Row(
                children: [
                  PhotoThumb(photo: widget.photo, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: widget.reportRefCode == null
                              ? RefTag(item.refCode)
                              : ClaimPair(
                                  item: item.refCode,
                                  report: widget.reportRefCode!,
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${itemTitle(item)} · ${widget.reportRefCode == null ? 'walk-in, no report' : 'confirmed match'}',
                          style: context.type.body.copyWith(
                            fontSize: 13.5,
                            color: c.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$done of 4 checks done',
                    style: context.type.strong.copyWith(fontSize: 15),
                  ),
                ),
                StatusPill(
                  valid ? 'Ready' : 'Not ready',
                  tone: valid ? Tone.ok : Tone.mute,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < checks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: checks[i] ? c.ok : c.surface2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (widget.matchId != null) ...[
              gap,
              OwnerAnswers(
                answers: widget.answers,
                privateNotes: item.privateNotes,
              ),
            ],
            gap,
            section(1, 'Before they see it'),
            const SizedBox(height: 12),
            DeskCard(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                title: const Text('Described it before seeing it'),
                subtitle: const Text('Ask them to describe it first.'),
                value: _described,
                onChanged: _busy ? null : (v) => setState(() => _described = v),
              ),
            ),
            const SizedBox(height: 10),
            DeskCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Owner-only details matched',
                          style: context.type.strong.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: c.line, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Fewer details',
                              onPressed: _busy || _details == 0
                                  ? null
                                  : () => setState(() => _details--),
                              icon: const Icon(Icons.remove),
                            ),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$_details',
                                key: const Key('details-count'),
                                textAlign: TextAlign.center,
                                style: context.type.mono.copyWith(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              tooltip: 'More details',
                              onPressed: _busy || _details == 5
                                  ? null
                                  : () => setState(() => _details++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EvidenceMark(
                        _details >= minimum
                            ? Evidence.agrees
                            : Evidence.missing,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'At least $minimum required for this item. Phones, wallets, IDs, keys, jewellery and high-value items require two.',
                          style: context.type.body.copyWith(
                            fontSize: 13,
                            color: c.ink2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            gap,
            section(2, 'Who is collecting'),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Photo ID seen',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in ReleaseRules.labels.entries)
                    if (e.key != 'none' || ReleaseRules.allowsNoId(item))
                      DeskChip(
                        label: e.value,
                        selected: _idType == e.key,
                        onTap: _busy
                            ? null
                            : () => setState(() => _idType = e.key),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: c.ink3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'We record the type only, never the number.',
                    style: context.type.small.copyWith(color: c.ink3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Claimant name',
              child: TextField(
                key: const Key('claimant-name'),
                controller: _name,
                enabled: !_busy,
                maxLength: 120,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            DeskCard(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                title: const Text('Someone else is collecting'),
                subtitle: const Text('Needs a note on who authorised it.'),
                value: _thirdParty,
                onChanged: _busy
                    ? null
                    : (v) => setState(() => _thirdParty = v),
              ),
            ),
            if (_thirdParty) ...[
              const SizedBox(height: 12),
              LabeledField(
                label: 'Authorisation note',
                hint:
                    'Record how the owner authorised this collector; do not enter ID numbers.',
                child: TextField(
                  key: const Key('authorisation-note'),
                  controller: _note,
                  enabled: !_busy,
                  maxLength: 300,
                  maxLines: 3,
                  minLines: 2,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
            gap,
            section(
              3,
              'Signature',
              trailing: const StatusPill('Optional'),
            ),
            const SizedBox(height: 12),
            DeskCard(
              child: SizedBox(
                height: 170,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Semantics(
                        label: 'Draw optional signature',
                        child: AbsorbPointer(
                          absorbing: _busy,
                          child: Signature(
                            key: const Key('release-signature'),
                            controller: _signature,
                            height: 170,
                            backgroundColor: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 36,
                      child: IgnorePointer(
                        child: DashedLine(
                          axis: Axis.horizontal,
                          length: 600,
                          thickness: 1.5,
                          color: DeskColors.light.line,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 12,
                      child: IgnorePointer(
                        child: Text(
                          'Sign above the line',
                          style: context.type.body.copyWith(
                            fontSize: 12,
                            color: DeskColors.light.ink3,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      bottom: 4,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: DeskColors.light.ink2,
                        ),
                        onPressed: _busy ? null : _signature.clear,
                        child: const Text('Clear signature'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StickyBar(
        note: widget.matchId != null
            ? 'The owner’s ticket updates straight away.'
            : 'Walk-in return. There is no ticket to update.',
        child: FilledButton(
          style: bigButtonStyle(context),
          onPressed: _busy || !valid ? null : _return,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check, size: 20),
              const SizedBox(width: 8),
              Text(_busy ? 'Returning…' : 'Mark as returned'),
            ],
          ),
        ),
      ),
    );
  }
}
