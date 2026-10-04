import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/desk_chip.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/match_actions.dart';
import '../ui/match_card.dart';
import '../ui/photo_view.dart';
import 'match_detail_screen.dart';

/// Proposals waiting for a staff decision.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, this.wide = false});
  final bool wide;
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _filter = 'all';
  (UuidValue, UuidValue)? _selected;

  Widget? _photo(VenueSession s, FoundItem item) => item.photoPath == null
      ? null
      : PhotoView(
          urls: s.photos,
          itemId: item.id!,
          thumb: true,
          revision: item.thumbPath,
          onDenied: s.onDenied,
        );

  void _open(VenueSession s, MatchCard card) {
    if (widget.wide) {
      setState(() => _selected = (card.match.id!, card.report.id!));
    } else {
      openDeskScreen(
        context,
        s,
        MatchDetailScreen(matchId: card.match.id!, reportId: card.report.id!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    final c = context.desk;
    final strong = s.inbox.where((m) => m.match.label == 'strong').length;
    final possible = s.inbox.where((m) => m.match.label == 'possible').length;
    final cards = s.inbox
        .where((m) => _filter == 'all' || m.match.label == _filter)
        .toList();
    final side = widget.wide ? 18.0 : 16.0;
    final header = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(side, widget.wide ? 26 : 4, side, 12),
        child: PageTitle('Inbox', trailing: '${s.inbox.length} to review'),
      ),
      ChipRow(
        padding: side,
        children: [
          DeskChip(
            label: 'All',
            selected: _filter == 'all',
            onTap: () => setState(() => _filter = 'all'),
          ),
          DeskChip(
            label: 'Strong · $strong',
            selected: _filter == 'strong',
            onTap: () => setState(() => _filter = 'strong'),
          ),
          DeskChip(
            label: 'Possible · $possible',
            selected: _filter == 'possible',
            onTap: () => setState(() => _filter = 'possible'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 2,
        child: s.inboxRefreshing && !s.inboxLoading
            ? const LinearProgressIndicator(minHeight: 2)
            : null,
      ),
    ];
    final notices = <Widget>[
      if (s.inboxError != null)
        RetryMessage(
          message: errorMessage(s.inboxError!),
          onRetry: s.refreshInbox,
        ),
      if (cards.isEmpty && s.inboxError == null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              const IconDisc(Icons.check, tone: DiscTone.ok, size: 48),
              const SizedBox(height: 16),
              Text(
                s.inbox.isEmpty ? 'Inbox clear' : 'Nothing in this view',
                style: context.type.headingAt(22),
              ),
              const SizedBox(height: 8),
              Text(
                'No matches to review. New reports and new items are compared automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.ink2),
              ),
            ],
          ),
        ),
    ];
    if (!widget.wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...header,
          Expanded(
            child: s.inboxLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: s.refreshInbox,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        ...notices,
                        for (final card in cards)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: MatchCardTile(
                              key: ValueKey(card.match.id),
                              card: card,
                              zoneName: s.zoneName(card.item.zoneId),
                              reportZoneName: card.report.zoneId == null
                                  ? null
                                  : s.zoneName(card.report.zoneId),
                              photo: _photo(s, card.item),
                              actions: MatchActions(
                                match: card.match,
                                onReview: () => _open(s, card),
                              ),
                              onTap: () => _open(s, card),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    }
    final selected =
        _selected ??
        (cards.isEmpty
            ? null
            : (cards.first.match.id!, cards.first.report.id!));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 400,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: c.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...header,
                Expanded(
                  child: s.inboxLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: s.refreshInbox,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                            children: [
                              ...notices,
                              for (final card in cards)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Semantics(
                                    selected: selected?.$1 == card.match.id,
                                    child: DeskCard(
                                      selected: selected?.$1 == card.match.id,
                                      child: MatchRow(
                                        card: card,
                                        photo: _photo(s, card.item),
                                        detail:
                                            '“${card.report.rawText.trim()}”',
                                        onTap: () => _open(s, card),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: selected == null
              ? Center(
                  child: Text(
                    'Choose a match to review it here.',
                    style: TextStyle(color: c.ink3),
                  ),
                )
              : MatchDetailScreen(
                  key: ValueKey(selected.$1),
                  matchId: selected.$1,
                  reportId: selected.$2,
                  embedded: true,
                ),
        ),
      ],
    );
  }
}
