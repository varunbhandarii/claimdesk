import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/categories.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/format.dart';
import '../ui/match_actions.dart';
import '../ui/match_card.dart';
import '../ui/owner_answers.dart';
import '../ui/photo_view.dart';
import '../ui/pills.dart';
import '../ui/status.dart';
import 'item_detail_screen.dart';
import 'release_screen.dart';

Evidence evidenceFor(double? value) => value == null
    ? Evidence.missing
    : value >= .5
    ? Evidence.agrees
    : Evidence.differs;

/// Side-by-side review of one proposal: strength, the two halves, how they
/// compare, the owner's proof and how the score was made.
class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.reportId,
    this.embedded = false,
  });
  final UuidValue matchId, reportId;

  /// Render without its own app bar, inside the wide inbox.
  final bool embedded;
  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  VenueSession? _session;
  MatchCard? _card;
  List<ReportAnswer> _answers = [];
  ReleaseSummary? _release;
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
      final answers = await _session!.client.match.answers(widget.matchId);
      final release = await _session!.client.release.releaseRecord(
        card.item.id!,
      );
      if (mounted) {
        setState(() {
          _card = card;
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

  Future<void> _returnItem() async {
    final s = _session!, c = _card!;
    final summary = await openDeskScreen<ReleaseSummary>(
      context,
      s,
      ReleaseScreen(
        item: c.item,
        matchId: c.match.id,
        reportRefCode: c.report.refCode,
        answers: _answers,
        photo: _photo(s, c.item, thumb: true),
      ),
    );
    if (summary == null || !mounted) return;
    if (widget.embedded) {
      await _load();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VenueScope(
          session: s,
          child: ItemDetailScreen(itemId: c.item.id!),
        ),
      ),
    );
  }

  Widget? _photo(VenueSession s, FoundItem item, {bool thumb = false}) =>
      item.photoPath == null
      ? null
      : PhotoView(
          urls: s.photos,
          itemId: item.id!,
          thumb: thumb,
          revision: thumb ? item.thumbPath : item.updatedAt,
          onDenied: s.onDenied,
          cover: true,
        );

  Widget _actions(MatchCard c) => MatchActions(
    match: c.match,
    onChanged: _load,
    reportStatus: c.report.status,
    releasedAt: _release?.record.releasedAt,
    onRelease: _returnItem,
  );

  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context), c = _card;
    final Widget body;
    if (c == null) {
      body = Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : RetryMessage(message: errorMessage(_error!), onRetry: _load),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, box) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: widget.embedded
                ? const EdgeInsets.fromLTRB(32, 26, 32, 40)
                : EdgeInsets.symmetric(
                    horizontal: box.maxWidth > 752
                        ? (box.maxWidth - 720) / 2
                        : 16,
                    vertical: 8,
                  ),
            children: _sections(context, s, c, box.maxWidth),
          ),
        ),
      );
    }
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Review match')),
      body: body,
      bottomNavigationBar: c == null ? null : StickyBar(child: _actions(c)),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    VenueSession s,
    MatchCard c,
    double width,
  ) {
    final d = context.desk;
    final wide = widget.embedded && width >= 760;
    const gap = SizedBox(height: 20);
    return [
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NoteStrip(
            icon: Icons.wifi_off,
            tone: DiscTone.warn,
            child: Text(errorMessage(_error!)),
          ),
        ),
      if (widget.embedded) ...[
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeskLabel('Proposed ${timeAgo(c.match.createdAt)}'),
                const SizedBox(height: 6),
                Text(
                  '${matchStrength(c.match.label)} match',
                  style: context.type.displayAt(36),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: _actions(c),
            ),
          ],
        ),
        gap,
      ],
      _scoreCard(context, c),
      gap,
      _halves(context, s, c, wide),
      gap,
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _compare(context, s, c)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _proof(c),
                  gap,
                  _signals(context, c),
                ],
              ),
            ),
          ],
        )
      else ...[
        _compare(context, s, c),
        gap,
        _proof(c),
        gap,
        _signals(context, c),
      ],
      if (c.match.decidedAt != null) ...[
        const SizedBox(height: 16),
        Text(
          '${matchStateLabel(c.match.state)} ${dateTimeLabel(c.match.decidedAt!, midSentence: true)}',
          style: context.type.small.copyWith(color: d.ink3),
        ),
      ],
      const SizedBox(height: 24),
    ];
  }

  Widget _scoreCard(BuildContext context, MatchCard c) {
    final m = c.match;
    return DeskCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DeskLabel('Match strength'),
                    const SizedBox(height: 4),
                    Text(
                      matchStrength(m.label),
                      style: context.type.headingAt(30, height: 1.1),
                    ),
                  ],
                ),
              ),
              Text(
                m.score.toStringAsFixed(2),
                style: context.type.mono.copyWith(fontSize: 36, height: 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ScoreMeter(score: m.score),
          if (m.state != MatchState.pending ||
              isPreliminary(m) ||
              c.clearLeader) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (m.state != MatchState.pending)
                  StatusPill(
                    matchStateLabel(m.state),
                    tone: matchStateTone(m.state),
                  ),
                if (isPreliminary(m))
                  const StatusPill('Preliminary', tone: Tone.draft),
                if (c.clearLeader)
                  const StatusPill(
                    'Clear leader',
                    tone: Tone.tag,
                    icon: Icons.star_outline,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _halves(BuildContext context, VenueSession s, MatchCard c, bool wide) {
    final d = context.desk;
    final item = c.item, report = c.report;
    final photo = _photo(s, item);
    final found = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: wide ? 230 : 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: photo == null
                    ? null
                    : () => openFullPhoto(context, s, item),
                child:
                    photo ??
                    ColoredBox(
                      color: d.surface2,
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: d.ink3,
                        semanticLabel: 'No photo',
                      ),
                    ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: RefTag(item.refCode, large: true),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeskLabel('Found item', colour: d.tagInk),
              const SizedBox(height: 4),
              Text(
                item.restricted ? 'Restricted item' : itemTitle(item),
                style: context.type.headingAt(21),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  dateTimeLabel(item.foundAt),
                  s.zoneName(item.zoneId),
                  ?item.storageBin,
                ].join(' · '),
                style: context.type.body.copyWith(fontSize: 13, color: d.ink3),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => openDeskScreen(
                    context,
                    s,
                    ItemDetailScreen(itemId: item.id!),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open item'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final lost = Padding(
      padding: wide
          ? const EdgeInsets.fromLTRB(8, 22, 24, 22)
          : const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RefTicket(report.refCode, large: true),
              const Spacer(),
              DeskLabel('Lost report', colour: d.ticket),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            '“${report.rawText.trim()}”',
            style: wide
                ? context.type.heading.copyWith(
                    fontSize: 21,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  )
                : context.type.body.copyWith(fontSize: 15.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          for (final (icon, text) in [
            (
              Icons.place_outlined,
              [
                if (report.zoneId != null) s.zoneName(report.zoneId),
                ?report.whereText,
              ].join(' · '),
            ),
            (
              Icons.calendar_today_outlined,
              report.lostAt == null
                  ? 'Day not given'
                  : report.lostAtFuzzyDays > 0
                  ? 'Around ${shortDate(report.lostAt!)}, day uncertain (±${report.lostAtFuzzyDays} days)'
                  : 'Lost ${shortDate(report.lostAt!)}',
            ),
            (
              Icons.schedule,
              'Filed ${dateTimeLabel(report.createdAt, midSentence: true)}',
            ),
          ])
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: d.ink2),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: context.type.body.copyWith(
                          fontSize: 13.5,
                          color: d.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
    return DeskCard(
      child: wide
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: found),
                  const VSeam(),
                  Expanded(child: lost),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [found, const Seam(), lost],
            ),
    );
  }

  Widget _compare(BuildContext context, VenueSession s, MatchCard c) {
    final d = context.desk;
    final item = c.item, report = c.report, e = c.match.explanation;
    final a = item.attributes;
    String dash(String? text) =>
        text == null || text.trim().isEmpty ? '—' : text.trim();
    final reportCategory = report.attributes?.category ?? report.categoryHint;
    final rows = [
      (
        'Category',
        a == null ? '—' : capitalise(fineLabel(a.category)),
        reportCategory == null || reportCategory == 'other'
            ? '—'
            : capitalise(fineLabel(reportCategory)),
        e.category,
      ),
      (
        'Colours',
        dash(a?.colours.map(colourLabel).join(', ')),
        dash(
          (report.attributes?.colours ?? report.colourHints)
              .map(colourLabel)
              .join(', '),
        ),
        e.colour,
      ),
      (
        'Zone',
        item.zoneId == null ? '—' : s.zoneName(item.zoneId),
        report.zoneId == null ? '—' : s.zoneName(report.zoneId),
        e.zone,
      ),
      (
        'When',
        shortDate(item.foundAt),
        report.lostAt == null
            ? '—'
            : report.lostAtFuzzyDays > 0
            ? 'Around ${shortDate(report.lostAt!)}'
            : shortDate(report.lostAt!),
        e.time,
      ),
      (
        'Marks',
        dash(a?.marks.join('; ')),
        e.matchedKeywords.isEmpty
            ? '—'
            : e.matchedKeywords.take(4).map((k) => '“$k”').join(', '),
        e.keywordCoverage,
      ),
      (
        'Brand',
        dash(a?.brand),
        dash(report.attributes?.brand ?? report.brandHint),
        e.brand,
      ),
    ];
    final text = context.type.body.copyWith(fontSize: 13.5, height: 1.35);
    Widget row(
      Widget label,
      Widget found,
      Widget lost,
      Widget mark, {
      Color? colour,
      bool top = true,
    }) => Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colour,
        border: top ? Border(top: BorderSide(color: d.line)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 76, child: label),
          const SizedBox(width: 8),
          Expanded(child: found),
          const SizedBox(width: 10),
          Expanded(child: lost),
          const SizedBox(width: 10),
          SizedBox(width: 24, child: mark),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('How they compare'),
        const SizedBox(height: 10),
        DeskCard(
          child: Column(
            children: [
              row(
                const SizedBox.shrink(),
                DeskLabel('Found', colour: d.tagInk),
                DeskLabel('Lost', colour: d.ticket),
                const SizedBox.shrink(),
                colour: d.paper,
                top: false,
              ),
              for (final (label, found, lost, value) in rows)
                row(
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DeskLabel(label),
                  ),
                  Text(found, style: text),
                  Text(lost, style: text),
                  EvidenceMark(evidenceFor(value)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _proof(MatchCard c) => OwnerAnswers(
    answers: _answers,
    postedAt: c.match.decidedAt,
    ownerOnlyDetails: c.report.ownerOnlyDetails,
    showOwnerOnly: true,
    privateNotes: c.item.privateNotes,
  );

  Widget _signals(BuildContext context, MatchCard c) {
    final d = context.desk;
    final e = c.match.explanation;
    final signals = [
      ('Meaning', e.cosSim),
      ('Keywords', e.keywordCoverage),
      ('Category', e.category),
      ('Colour', e.colour),
      ('Brand', e.brand),
      ('Zone', e.zone),
      ('Time', e.time),
    ];
    return DeskCard(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Text(
          'How the score was made',
          style: context.type.strong.copyWith(fontSize: 16),
        ),
        children: [
          for (final (name, value) in signals)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      name,
                      style: context.type.body.copyWith(
                        fontSize: 13.5,
                        color: value == null ? d.ink3 : d.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    child: value == null
                        ? Text(
                            'No evidence · left out',
                            style: context.type.body.copyWith(
                              fontSize: 12.5,
                              color: d.ink3,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: value.clamp(0.0, 1.0),
                              minHeight: 6,
                              color: d.ink,
                              backgroundColor: d.surface2,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      value == null ? '' : value.toStringAsFixed(2),
                      textAlign: TextAlign.right,
                      style: context.type.mono.copyWith(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          if (e.guardrailApplied)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NoteStrip(
                icon: Icons.shield_outlined,
                tone: DiscTone.warn,
                child: const Text(
                  'Category and brand disagreement capped the score.',
                ),
              ),
            ),
          Text(
            'Signals with no evidence are left out rather than counted against the match.',
            style: context.type.small.copyWith(color: d.ink3),
          ),
          const SizedBox(height: 6),
          Text(
            'Algorithm ${c.match.algorithmVersion} · weights ${e.weightsHash}',
            style: context.type.mono.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: d.ink3,
            ),
          ),
        ],
      ),
    );
  }
}
