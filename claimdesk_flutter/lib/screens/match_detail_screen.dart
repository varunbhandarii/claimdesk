import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/attribute_chips.dart';
import '../ui/match_actions.dart';
import '../ui/match_chips.dart';
import '../ui/photo_view.dart';
import '../ui/status.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.reportId,
  });
  final UuidValue matchId, reportId;
  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  VenueSession? _session;
  MatchCard? _card;
  Object? _error;
  DeskEvent? _last;
  int _revision = -1;
  bool _loading = false, _again = false;
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
    final e = s.lastEvent;
    if (_revision != s.reconnectRevision ||
        (e != null &&
            !identical(e, _last) &&
            (e.matchId == widget.matchId || e.reportId == widget.reportId))) {
      _revision = s.reconnectRevision;
      _last = e;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    if (_loading) {
      _again = true;
      return;
    }
    _loading = true;
    try {
      final cards = await _session!.client.match.forReport(widget.reportId);
      final card = cards.where((c) => c.match.id == widget.matchId).firstOrNull;
      if (card == null) {
        throw StateError('This proposal is no longer available.');
      }
      if (mounted) {
        setState(() {
          _card = card;
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

  String _date(DateTime? date) =>
      date?.toLocal().toString().split('.').first ?? 'Not set';
  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context), c = _card;
    return Scaffold(
      appBar: AppBar(title: const Text('Match review')),
      body: c == null
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
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_error != null) Text(errorMessage(_error!)),
                      SizedBox(
                        height: 280,
                        child: PhotoView(
                          urls: s.photos,
                          itemId: c.item.id!,
                          revision: c.item.updatedAt,
                          onDenied: s.onDenied,
                        ),
                      ),
                      Text(
                        'Item ${c.item.refCode}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (c.item.attributes != null)
                        AttributeChips(
                          attributes: c.item.attributes!,
                          restricted: c.item.restricted,
                        ),
                      Text(
                        'Found: ${_date(c.item.foundAt)} · ${s.zoneName(c.item.zoneId)}',
                      ),
                      Text('Storage bin: ${c.item.storageBin ?? 'Not set'}'),
                      Text(
                        'Private notes · staff only: ${c.item.privateNotes ?? 'None'}',
                      ),
                      const Divider(height: 32),
                      Text(
                        'Report ${c.report.refCode}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(c.report.rawText),
                      Text(
                        'Hints: ${[c.report.categoryHint, ...c.report.colourHints, c.report.brandHint].whereType<String>().join(' · ')}',
                      ),
                      Text(
                        'Lost: ${_date(c.report.lostAt)}${c.report.lostAtFuzzyDays > 0 ? ' · ±${c.report.lostAtFuzzyDays} days' : ''} · ${s.zoneName(c.report.zoneId)}',
                      ),
                      if (c.report.whereText != null) Text(c.report.whereText!),
                      const SizedBox(height: 16),
                      const Text(
                        'Owner-only details · staff only',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SelectableText(
                        c.report.ownerOnlyDetails ?? 'Not provided',
                      ),
                      const Divider(height: 32),
                      Text(
                        '${matchStateLabel(c.match.state)} · ${c.match.label} · ${c.match.score.toStringAsFixed(2)}',
                      ),
                      if (c.match.decidedAt != null)
                        Text(
                          'Decided by ${c.match.decidedByAuthUserId} at ${_date(c.match.decidedAt)}',
                        ),
                      MatchChips(
                        explanation: c.match.explanation,
                        item: c.item,
                        report: c.report,
                        zoneName: s.zoneName(c.item.zoneId),
                      ),
                      ExpansionTile(
                        title: const Text('Score details'),
                        children: [
                          for (final signal in {
                            'Cosine similarity': c.match.explanation.cosSim,
                            'Keyword coverage':
                                c.match.explanation.keywordCoverage,
                            'Category': c.match.explanation.category,
                            'Colour': c.match.explanation.colour,
                            'Brand': c.match.explanation.brand,
                            'Zone': c.match.explanation.zone,
                            'Time': c.match.explanation.time,
                          }.entries)
                            ListTile(
                              title: Text(signal.key),
                              trailing: Text(
                                signal.value?.toStringAsFixed(3) ??
                                    'No evidence',
                              ),
                            ),
                          ListTile(
                            title: Text(
                              'Algorithm ${c.match.algorithmVersion} · weights ${c.match.explanation.weightsHash}',
                            ),
                          ),
                          if (c.match.explanation.guardrailApplied)
                            const ListTile(
                              title: Text(
                                'Category and brand disagreement capped the score.',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MatchActions(match: c.match, onChanged: _load),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
