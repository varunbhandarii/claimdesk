import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/categories.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/format.dart';
import '../ui/history_list.dart';
import '../ui/match_list.dart';
import '../ui/owner_answers.dart';
import '../ui/release_receipt.dart';
import '../ui/status.dart';
import 'match_detail_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final UuidValue reportId;
  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  VenueSession? _session;
  LostReport? _report;
  List<MatchCard> _matches = [];
  List<ReportAnswer> _answers = [];
  List<HistoryEntry> _history = [];
  ReleaseSummary? _release;
  bool _rematching = false;
  Object? _error;
  DeskEvent? _event;
  int _revision = -1;
  bool _loading = false, _again = false, _acting = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = VenueScope.of(context);
    if (_session == s) return;
    _session?.removeListener(_changed);
    _session = s;
    s.addListener(_changed);
    _load();
  }

  void _changed() {
    final s = _session!;
    if (_revision != s.reconnectRevision) {
      _revision = s.reconnectRevision;
      unawaited(_load());
    }
    final event = s.lastEvent;
    if (event != null && !identical(event, _event)) {
      _event = event;
      if (event.reportId == widget.reportId) {
        if ({'matchCreated', 'reportStatus'}.contains(event.kind)) {
          _rematching = false;
        }
        unawaited(_load());
      }
    }
  }

  Future<void> _load() async {
    if (_loading) {
      _again = true;
      return;
    }
    _loading = true;
    try {
      final report = await _session!.client.report.getReport(widget.reportId);
      final history = await _session!.client.report.history(widget.reportId);
      final matches = await _session!.client.match.forReport(widget.reportId);
      final confirmed = matches
          .where((c) => c.match.state == MatchState.confirmed)
          .firstOrNull;
      final answers = confirmed == null
          ? <ReportAnswer>[]
          : await _session!.client.match.answers(confirmed.match.id!);
      final release =
          report.status != ReportStatus.returned || confirmed == null
          ? null
          : await _session!.client.release.releaseRecord(confirmed.item.id!);
      if (mounted) {
        setState(() {
          _report = report;
          _history = history;
          _matches = matches;
          _answers = answers;
          _release = release;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
        if (e is NotAMemberException) _session!.onDenied();
      }
    } finally {
      _loading = false;
      if (_again && mounted) {
        _again = false;
        unawaited(_load());
      }
    }
  }

  @override
  void dispose() {
    _session?.removeListener(_changed);
    super.dispose();
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied.')));
    }
  }

  Future<void> _close() async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Close this report?'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            maxLength: 300,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              helperText: 'The owner will see that the report was closed.',
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Give a reason.' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(dialog, controller.text.trim());
              }
            },
            child: const Text('Close report'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    setState(() => _acting = true);
    await runGuarded(context, () async {
      final report = await _session!.client.report.closeReport(
        widget.reportId,
        reason,
      );
      if (mounted) setState(() => _report = report);
      await _session!.refreshReports();
    }, onDenied: _session!.onDenied);
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _rematch() async {
    setState(() => _rematching = true);
    final job = await runGuarded(
      context,
      () => _session!.client.match.rematch(widget.reportId),
      onDenied: _session!.onDenied,
    );
    if (mounted && job == null) setState(() => _rematching = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    final r = _report;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost report'),
        actions: [
          if (r != null)
            IconButton(
              onPressed: () => _copy(r.refCode),
              tooltip: 'Copy reference',
              icon: const Icon(Icons.copy),
            ),
        ],
      ),
      body: r == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : RetryMessage(
                      message: errorMessage(_error!),
                      onRetry: _load,
                    ),
            )
          : LayoutBuilder(
              builder: (context, box) => RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    box.maxWidth > 752 ? (box.maxWidth - 720) / 2 : 16,
                    4,
                    box.maxWidth > 752 ? (box.maxWidth - 720) / 2 : 16,
                    40,
                  ),
                  children: _sections(context, s, r),
                ),
              ),
            ),
    );
  }

  List<Widget> _sections(BuildContext context, VenueSession s, LostReport r) {
    final c = context.desk;
    const gap = SizedBox(height: 22);
    final confirmed = _matches
        .where((m) => m.match.state == MatchState.confirmed)
        .toList();
    final verifying = {
      ReportStatus.possibleMatch,
      ReportStatus.readyForPickup,
    }.contains(r.status);
    final lost = r.lostAt == null
        ? 'Not given'
        : r.lostAtFuzzyDays > 0
        ? 'Around ${shortDate(r.lostAt!)} (±${r.lostAtFuzzyDays} days)'
        : shortDate(r.lostAt!);
    return [
      DeskCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: c.ticket,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DeskLabel(
                          'Lost report',
                          colour: c.ticketOn.withValues(alpha: .82),
                        ),
                      ),
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.ticketOn,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          reportStatusLabel(r.status),
                          style: context.type.strong.copyWith(
                            fontSize: 12.5,
                            height: 1,
                            color: c.ticket,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    r.refCode,
                    style: context.type
                        .codeAt(32)
                        .copyWith(
                          color: c.ticketOn,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ),
            const Seam(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    '“${r.rawText.trim()}”',
                    style: context.type.heading.copyWith(
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (r.categoryHint != null)
                        Text(
                          categoryLabel(r.categoryHint!),
                          style: context.type.strong.copyWith(
                            fontSize: 14,
                            color: c.ink2,
                          ),
                        ),
                      ColourNames(r.colourHints),
                      if (r.brandHint != null)
                        Text(
                          r.brandHint!,
                          style: TextStyle(fontSize: 14, color: c.ink2),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (r.lastMatchOutcome == 'match_failed') ...[
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: MatchingUnavailable(),
        ),
      ],
      if (_error != null) ...[
        const SizedBox(height: 12),
        NoteStrip(
          icon: Icons.wifi_off,
          tone: DiscTone.warn,
          child: Text(errorMessage(_error!)),
        ),
      ],
      gap,
      KvGrid([
        ('Where', r.zoneId == null ? 'Not sure' : s.zoneName(r.zoneId)),
        ('Lost', lost),
        if (r.whereText != null) ('More precisely', r.whereText!),
        ('Filed', dateTimeLabel(r.createdAt)),
        ('Updated', dateTimeLabel(r.updatedAt)),
        if (r.closedAt != null) ('Closed', dateTimeLabel(r.closedAt!)),
      ]),
      if (_release != null) ...[gap, ReleaseReceipt(summary: _release!)],
      if (verifying) ...[
        gap,
        OwnerAnswers(
          answers: _answers,
          postedAt: confirmed.firstOrNull?.match.decidedAt,
          ownerOnlyDetails: r.ownerOnlyDetails,
          showOwnerOnly: true,
        ),
        for (final match in confirmed) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => openDeskScreen(
              context,
              s,
              MatchDetailScreen(matchId: match.match.id!, reportId: r.id!),
            ),
            icon: const Icon(Icons.compare_arrows, size: 20),
            label: const Text('Review confirmed match'),
          ),
        ],
      ],
      gap,
      SectionTitle(
        'Candidates',
        trailing:
            {
              ReportStatus.received,
              ReportStatus.searching,
              ReportStatus.possibleMatch,
            }.contains(r.status)
            ? TextButton.icon(
                onPressed: _rematching ? null : _rematch,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(_rematching ? 'Searching…' : 'Search again'),
              )
            : null,
      ),
      const SizedBox(height: 10),
      MatchList(cards: _matches, showReports: false),
      gap,
      HistoryList(entries: _history),
      gap,
      DeskCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconDisc(Icons.lock_outline, size: 30, iconSize: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Owner and contact',
                    style: context.type.headingAt(18),
                  ),
                ),
                const DeskLabel('Staff only'),
              ],
            ),
            if (!verifying) ...[
              const SizedBox(height: 14),
              const DeskLabel('Only the owner would know'),
              const SizedBox(height: 4),
              SelectableText(r.ownerOnlyDetails ?? 'Not provided'),
            ],
            const SizedBox(height: 14),
            const DeskLabel('Contact'),
            const SizedBox(height: 4),
            if (r.contactEmail == null && r.ownerName == null)
              Text(
                'Contact details have been removed.',
                style: TextStyle(color: c.ink3),
              ),
            if (r.ownerName != null)
              _copyRow(context, Icons.person_outline, r.ownerName!),
            if (r.contactEmail != null)
              _copyRow(context, Icons.mail_outline, r.contactEmail!),
          ],
        ),
      ),
      if ({
        ReportStatus.received,
        ReportStatus.searching,
      }.contains(r.status)) ...[
        gap,
        OutlinedButton(
          onPressed: _acting ? null : _close,
          child: Text(_acting ? 'Closing…' : 'Close report'),
        ),
      ],
    ];
  }

  Widget _copyRow(BuildContext context, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: context.desk.ink2),
      const SizedBox(width: 8),
      Expanded(child: SelectableText(text)),
      IconButton(
        tooltip: 'Copy',
        onPressed: () => _copy(text),
        icon: const Icon(Icons.copy, size: 18),
      ),
    ],
  );
}
