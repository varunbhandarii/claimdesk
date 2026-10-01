import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/status.dart';
import '../ui/categories.dart';
import '../ui/match_list.dart';
import '../ui/owner_answers.dart';
import '../ui/release_receipt.dart';
import '../app/routes.dart';
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

  String _date(DateTime? date) =>
      date?.toLocal().toString().split('.').first ?? 'Not set';
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
      appBar: AppBar(title: const Text('Lost report')),
      body: r == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(errorMessage(_error!)),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.refCode,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copy(r.refCode),
                          tooltip: 'Copy reference',
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    ReportStatusChip(r.status),
                    if (_release != null) ReleaseReceipt(summary: _release!),
                    if ({
                      ReportStatus.possibleMatch,
                      ReportStatus.readyForPickup,
                    }.contains(r.status)) ...[
                      OwnerAnswers(
                        answers: _answers,
                        postedAt: _matches
                            .where((c) => c.match.state == MatchState.confirmed)
                            .firstOrNull
                            ?.match
                            .decidedAt,
                      ),
                      for (final confirmed in _matches.where(
                        (c) => c.match.state == MatchState.confirmed,
                      ))
                        TextButton(
                          onPressed: () => openDeskScreen(
                            context,
                            s,
                            MatchDetailScreen(
                              matchId: confirmed.match.id!,
                              reportId: r.id!,
                            ),
                          ),
                          child: const Text('Review confirmed match'),
                        ),
                    ],
                    if (r.lastMatchOutcome == 'match_failed')
                      const MatchingUnavailable(),
                    if (_error != null) Text(errorMessage(_error!)),
                    const SizedBox(height: 16),
                    Text(
                      r.rawText,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (r.categoryHint != null)
                          Chip(label: Text(categoryLabel(r.categoryHint!))),
                        for (final colour in r.colourHints)
                          Chip(label: Text(colour)),
                        if (r.brandHint != null)
                          Chip(label: Text(r.brandHint!)),
                      ],
                    ),
                    Text('Where: ${s.zoneName(r.zoneId)}'),
                    if (r.whereText != null) Text(r.whereText!),
                    Text(
                      'Lost: ${_date(r.lostAt)}${r.lostAtFuzzyDays > 0 ? ' · day uncertain (±${r.lostAtFuzzyDays} days)' : ''}',
                    ),
                    Text('Filed: ${_date(r.createdAt)}'),
                    Text('Updated: ${_date(r.updatedAt)}'),
                    if (r.closedAt != null)
                      Text('Closed: ${_date(r.closedAt)}'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Candidates',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if ({
                          ReportStatus.received,
                          ReportStatus.searching,
                          ReportStatus.possibleMatch,
                        }.contains(r.status))
                          TextButton(
                            onPressed: _rematching ? null : _rematch,
                            child: Text(
                              _rematching ? 'Searching…' : 'Search again',
                            ),
                          ),
                      ],
                    ),
                    MatchList(cards: _matches),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Owner-only details · staff only',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              r.ownerOnlyDetails ?? 'Not provided',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Contact · staff only',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (r.contactEmail != null)
                              TextButton(
                                onPressed: () => _copy(r.contactEmail!),
                                child: Text(r.contactEmail!),
                              ),
                            if (r.ownerName != null)
                              TextButton(
                                onPressed: () => _copy(r.ownerName!),
                                child: Text(r.ownerName!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if ({
                      ReportStatus.received,
                      ReportStatus.searching,
                    }.contains(r.status))
                      FilledButton(
                        onPressed: _acting ? null : _close,
                        child: Text(_acting ? 'Closing…' : 'Close report'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
