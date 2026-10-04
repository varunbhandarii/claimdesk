import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../data/errors.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/format.dart';
import '../ui/match_card.dart';

String attentionLabel(String value) => switch (value) {
  'captioningFailed' => 'Captioning failed',
  'overdue' => 'Overdue hand-offs',
  'expiringSoon' => 'Expiring within three days',
  _ => value,
};

const _numbers = ['One', 'Two', 'Three', 'Four', 'Five'];

/// "Two things need you." for the number of groups that need attention.
String deskHeadline(int groups) => groups == 0
    ? 'Nothing needs you right now.'
    : groups == 1
    ? 'One thing needs you.'
    : '${_numbers[(groups - 1).clamp(0, 4)]} things need you.';

class DeskScreen extends StatelessWidget {
  const DeskScreen({
    super.key,
    required this.summary,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onItems,
    required this.onInbox,
    required this.onReports,
    required this.onItem,
    this.matches = const [],
    this.photoFor,
    this.zoneName,
    this.onMatch,
    this.onExport,
    this.now,
  });
  final DeskSummary? summary;
  final bool loading;
  final Object? error;
  final Future<void> Function() onRefresh;
  final void Function(String? attention, ItemStatus? status) onItems;
  final VoidCallback onInbox, onReports;
  final void Function(UuidValue) onItem;
  final List<MatchCard> matches;
  final Widget? Function(FoundItem item)? photoFor;
  final String Function(UuidValue? zoneId)? zoneName;
  final void Function(MatchCard card)? onMatch;
  final VoidCallback? onExport;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final data = summary;
    if (loading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 900;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: wide
                ? const EdgeInsets.fromLTRB(40, 30, 40, 48)
                : const EdgeInsets.fromLTRB(16, 6, 16, 120),
            children: [
              _header(context, data, wide),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: NoteStrip(
                    icon: Icons.wifi_off,
                    tone: DiscTone.warn,
                    child: Row(
                      children: [
                        Expanded(child: Text(errorMessage(error!))),
                        TextButton(
                          onPressed: onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (data != null) ...[
                SizedBox(height: wide ? 24 : 20),
                _stats(data, wide),
                SizedBox(height: wide ? 24 : 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _matchesCard(context, data, wide)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _attention(context, data, wide),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _matchesCard(context, data, wide),
                  ..._attention(context, data, wide),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  int _groups(DeskSummary data) => [
    data.newMatches,
    data.overdueCount,
    data.expiredCount,
    data.expiringSoonCount,
    data.captioningFailedCount,
  ].where((count) => count > 0).length;

  Widget _header(BuildContext context, DeskSummary? data, bool wide) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeskLabel(longDay(now ?? DateTime.now())),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            data == null ? 'Desk' : deskHeadline(_groups(data)),
            style: context.type.displayAt(wide ? 42 : 34),
          ),
        ),
      ],
    );
    if (!wide || onExport == null) return title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.file_download_outlined, size: 20),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _stats(DeskSummary data, bool wide) {
    final tiles = [
      StatTile(
        value: data.onShelf,
        label: 'On shelf',
        large: wide,
        onTap: () => onItems(null, ItemStatus.unclaimed),
      ),
      StatTile(
        value: data.openReports,
        label: 'Open reports',
        large: wide,
        onTap: onReports,
      ),
      if (wide)
        StatTile(
          value: data.newMatches,
          label: 'Matches to review',
          large: wide,
          onTap: onInbox,
        ),
      StatTile(
        value: data.returnedThisWeek,
        label: 'Returned in 7 days',
        large: wide,
        onTap: () => onItems(null, ItemStatus.claimed),
      ),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) SizedBox(width: wide ? 12 : 8),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }

  Widget _matchesCard(BuildContext context, DeskSummary data, bool wide) {
    final c = context.desk;
    final strong = matches.where((m) => m.match.label == 'strong').length;
    final possible = matches.where((m) => m.match.label == 'possible').length;
    final shown = matches.take(wide ? 5 : 3).toList();
    return DeskCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onInbox,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matches to review',
                          style: context.type.headingAt(20),
                        ),
                        if (matches.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$strong strong · $possible possible',
                            style: context.type.body.copyWith(
                              fontSize: 13,
                              color: c.ink3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${data.newMatches}',
                    style: context.type.mono.copyWith(fontSize: 30),
                  ),
                ],
              ),
            ),
          ),
          if (data.newMatches == 0 || shown.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                data.newMatches == 0
                    ? 'No matches waiting. New reports and items are compared automatically.'
                    : 'Open the inbox to review them.',
                style: context.type.body.copyWith(fontSize: 14, color: c.ink2),
              ),
            ),
          for (final card in shown)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: MatchRow(
                card: card,
                photo: photoFor?.call(card.item),
                onTap: () => onMatch == null ? onInbox() : onMatch!.call(card),
              ),
            ),
          if (data.newMatches > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: onInbox,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Review all ${data.newMatches}'),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _attention(BuildContext context, DeskSummary data, bool wide) {
    final groups = [
      _Group(
        key: 'overdue',
        title: attentionLabel('overdue'),
        subtitle: 'Past the police hand-off date. Hand them over today.',
        icon: Icons.local_police_outlined,
        tone: DiscTone.bad,
        count: data.overdueCount,
        items: data.overdue,
        detail: (i) => i.handoffDueAt == null
            ? 'Hand-off overdue'
            : 'Hand-off was due ${shortDate(i.handoffDueAt!, now: now)}',
        open: () => onItems('overdue', null),
        clear: 'No overdue police hand-offs',
      ),
      _Group(
        key: 'expired',
        title: 'Expired, waiting for you',
        subtitle: 'Hold time is over. Each item shows its recommended action.',
        icon: Icons.warning_amber_rounded,
        tone: DiscTone.warn,
        count: data.expiredCount,
        items: data.expired,
        detail: (i) => i.holdUntil == null
            ? 'Hold ended'
            : 'Hold ended ${shortDate(i.holdUntil!, now: now)}',
        open: () => onItems(null, ItemStatus.expired),
        clear: 'Nothing waiting for disposal',
      ),
      _Group(
        key: 'expiringSoon',
        title: attentionLabel('expiringSoon'),
        subtitle: 'Hold ends soon. Check for owners first.',
        icon: Icons.schedule,
        tone: DiscTone.warn,
        count: data.expiringSoonCount,
        items: data.expiringSoon,
        detail: (i) => i.holdUntil == null
            ? 'Hold ends soon'
            : 'Hold ends ${shortDate(i.holdUntil!, now: now)}',
        open: () => onItems('expiringSoon', null),
        clear: 'Nothing expiring in the next three days',
      ),
      _Group(
        key: 'captioningFailed',
        title: attentionLabel('captioningFailed'),
        subtitle: 'The photo could not be described. Add details by hand.',
        icon: Icons.hide_image_outlined,
        tone: DiscTone.warn,
        count: data.captioningFailedCount,
        items: data.captioningFailed,
        detail: (i) => 'Logged ${timeAgo(i.createdAt, now: now)}',
        open: () => onItems('captioningFailed', null),
        clear: 'No failed captions',
      ),
    ];
    final active = groups.where((g) => g.count > 0).toList();
    final clear = groups.where((g) => g.count == 0).toList();
    final gap = SizedBox(height: wide ? 20 : 16);
    return [
      for (final group in active) ...[
        if (!wide || group != active.first) gap,
        _AttentionCard(group: group, photoFor: photoFor, onItem: onItem),
      ],
      if (clear.isNotEmpty) ...[
        if (!wide || active.isNotEmpty) gap,
        _allClear(context, clear, wide),
      ],
      if (data.recent.isNotEmpty) ...[
        SizedBox(height: wide ? 20 : 24),
        _recent(context, data.recent, wide),
      ],
    ];
  }

  Widget _allClear(BuildContext context, List<_Group> clear, bool wide) {
    final lines = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DeskLabel('All clear'),
        for (final group in clear) ...[
          const SizedBox(height: 10),
          EvidenceLine(Evidence.agrees, group.clear),
        ],
      ],
    );
    return wide
        ? DeskCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: lines,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: lines,
          );
  }

  Widget _recent(BuildContext context, List<FoundItem> recent, bool wide) {
    final c = context.desk;
    Widget tile(FoundItem item, double size) => InkWell(
      onTap: () => onItem(item.id!),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photoFor?.call(item) ??
                      ColoredBox(
                        color: c.surface2,
                        child: Icon(
                          Icons.image_outlined,
                          color: c.ink3,
                          semanticLabel: 'No photo',
                        ),
                      ),
                  Positioned(left: 6, bottom: 6, child: RefTag(item.refCode)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            itemTitle(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.strong.copyWith(fontSize: 13.5, height: 1.25),
          ),
          Text(
            [
              if (zoneName != null) zoneName!(item.zoneId),
              ageShort(item.createdAt, now: now),
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.body.copyWith(fontSize: 12, color: c.ink3),
          ),
        ],
      ),
    );
    final title = SectionTitle(
      'Recently logged',
      size: wide ? 21 : 20,
      trailing: TextButton(
        onPressed: () => onItems(null, null),
        child: const Text('All items'),
      ),
    );
    if (wide) {
      return DeskCard(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) {
                final size = ((box.maxWidth - 30) / 4).floorToDouble();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      SizedBox(
                        width: size,
                        child: i < recent.length
                            ? tile(recent[i], size)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        const SizedBox(height: 8),
        SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: recent.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, index) =>
                SizedBox(width: 128, child: tile(recent[index], 128)),
          ),
        ),
      ],
    );
  }
}

class _Group {
  const _Group({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.count,
    required this.items,
    required this.detail,
    required this.open,
    required this.clear,
  });
  final String key, title, subtitle, clear;
  final IconData icon;
  final DiscTone tone;
  final int count;
  final List<FoundItem> items;
  final String Function(FoundItem item) detail;
  final VoidCallback open;
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.group,
    required this.photoFor,
    required this.onItem,
  });
  final _Group group;
  final Widget? Function(FoundItem item)? photoFor;
  final void Function(UuidValue) onItem;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return DeskCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: group.open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconDisc(group.icon, tone: group.tone, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.title, style: context.type.headingAt(20)),
                        const SizedBox(height: 4),
                        Text(
                          group.subtitle,
                          style: context.type.body.copyWith(
                            fontSize: 13,
                            color: c.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${group.count}',
                    style: context.type.mono.copyWith(fontSize: 30),
                  ),
                ],
              ),
            ),
          ),
          for (final item in group.items.take(3))
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: InkWell(
                onTap: () => onItem(item.id!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      PhotoThumb(
                        photo: photoFor?.call(item),
                        size: 48,
                        locked: item.restricted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RefTag(item.refCode),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    itemTitle(item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.type.strong.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              group.detail(item),
                              style: context.type.small.copyWith(
                                color: c.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: c.ink3),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (group.count > group.items.take(3).length &&
                    group.items.isNotEmpty) ...[
                  Text(
                    'Showing ${group.items.take(3).length} of ${group.count}',
                    style: context.type.small.copyWith(color: c.ink3),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: group.open,
                  child: Text('See all ${group.count}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
