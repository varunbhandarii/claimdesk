import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/action_tile.dart';
import '../ui/attribute_chips.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/format.dart';
import '../ui/history_list.dart';
import '../ui/item_badges.dart';
import '../ui/item_form.dart';
import '../ui/match_list.dart';
import '../ui/photo_view.dart';
import '../ui/pills.dart';
import '../ui/release_receipt.dart';
import '../ui/status.dart';
import '../ui/tag_button.dart';
import '../ui/transfer_sheet.dart';
import 'edit_item_screen.dart';
import 'match_detail_screen.dart';
import 'release_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final UuidValue itemId;
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  VenueSession? _session;
  FoundItem? _item;
  List<HistoryEntry> _history = [];
  List<CustodyEvent> _custody = [];
  List<MatchCard> _matches = [];
  ReleaseSummary? _release;
  Object? _error;
  DeskEvent? _lastEvent;
  int _reconnectRevision = 0;
  bool _loading = false;
  bool _again = false;
  bool _acting = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = VenueScope.of(context);
    if (_session == session) return;
    _session?.removeListener(_changed);
    _session = session;
    session.addListener(_changed);
    _load();
  }

  void _changed() {
    if (_reconnectRevision != _session!.reconnectRevision) {
      _reconnectRevision = _session!.reconnectRevision;
      _load();
    }
    final event = _session!.lastEvent;
    if (event != null && !identical(event, _lastEvent)) {
      _lastEvent = event;
      if (event.itemId == widget.itemId) _load();
    }
  }

  Future<void> _load() async {
    if (_loading) {
      _again = true;
      return;
    }
    _loading = true;
    try {
      final item = await _session!.client.item.getItem(widget.itemId);
      final history = await _session!.client.item.history(widget.itemId);
      final custody = await _session!.client.item.custody(widget.itemId);
      final matches = await _session!.client.match.forItem(widget.itemId);
      final release = await _session!.client.release.releaseRecord(
        widget.itemId,
      );
      if (mounted) {
        setState(() {
          _item = item;
          _history = history;
          _custody = custody;
          _matches = matches;
          _release = release;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
        if (e is NotAMemberException) _session!.onDenied();
      }
    } finally {
      _loading = false;
      if (_again && mounted) {
        _again = false;
        _load();
      }
    }
  }

  @override
  void dispose() {
    _session?.removeListener(_changed);
    super.dispose();
  }

  Future<void> _recaption() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caption this photo again?'),
        content: const Text(
          'The new caption replaces the current attributes. Your private notes stay with the item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Recaption'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _acting = true);
    await runGuarded(context, () async {
      await _session!.client.item.recaption(widget.itemId);
      await _load();
    }, onDenied: _session!.onDenied);
    if (mounted) setState(() => _acting = false);
  }

  String? get _recommendation => _history
      .where((e) => e.action == 'expired')
      .firstOrNull
      ?.data['recommendedAction'];

  Future<void> _transfer() async {
    final input = await showModalBottomSheet<TransferInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TransferSheet(),
    );
    if (input == null || !mounted) return;
    setState(() => _acting = true);
    await runGuarded(context, () async {
      await _session!.client.item.transfer(widget.itemId, input);
      await _load();
    }, onDenied: _session!.onDenied);
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _disposeItem() async {
    final input = await showModalBottomSheet<DisposeInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DisposeSheet(recommendedAction: _recommendation),
    );
    if (input == null || !mounted) return;
    setState(() => _acting = true);
    await runGuarded(context, () async {
      await _session!.client.item.dispose(widget.itemId, input);
      await _load();
    }, onDenied: _session!.onDenied);
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _edit(FoundItem item) async {
    final edited = await openDeskScreen<FoundItem>(
      context,
      _session!,
      EditItemScreen(item: item),
    );
    if (edited != null && mounted) setState(() => _item = edited);
  }

  Future<void> _return(FoundItem item) async {
    final session = _session!;
    final reserved = _matches
        .where((c) => c.match.state == MatchState.confirmed)
        .firstOrNull;
    List<ReportAnswer> answers = const [];
    if (reserved != null) {
      setState(() => _acting = true);
      final loaded = await runGuarded(
        context,
        () => session.client.match.answers(reserved.match.id!),
        onDenied: session.onDenied,
      );
      if (mounted) setState(() => _acting = false);
      if (loaded == null || !mounted) return;
      answers = loaded;
    }
    final released = await openDeskScreen<ReleaseSummary>(
      context,
      session,
      ReleaseScreen(
        item: item,
        matchId: reserved?.match.id,
        reportRefCode: reserved?.report.refCode,
        answers: answers,
        photo: item.photoPath == null
            ? null
            : PhotoView(
                urls: session.photos,
                itemId: item.id!,
                thumb: true,
                revision: item.thumbPath,
                onDenied: session.onDenied,
              ),
      ),
    );
    if (released != null) await _load();
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Copied $code.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Found item')),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : RetryMessage(message: errorMessage(_error!), onRetry: _load),
        ),
      );
    }
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final framed = box.maxWidth > 760;
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: framed
                  ? EdgeInsets.fromLTRB(
                      (box.maxWidth - 720) / 2,
                      16,
                      (box.maxWidth - 720) / 2,
                      40,
                    )
                  : const EdgeInsets.only(bottom: 40),
              children: [
                _top(context, item, framed),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: framed ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _body(context, item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _top(BuildContext context, FoundItem item, bool framed) {
    final c = context.desk;
    final session = _session!;
    final heroHeight = framed ? 360.0 : 300.0;
    Widget round(Widget child) => Material(
      color: c.surface.withValues(alpha: .94),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    final photo = item.photoPath == null
        ? null
        : PhotoView(
            urls: session.photos,
            itemId: item.id!,
            revision: item.updatedAt,
            onDenied: session.onDenied,
            cover: true,
            semanticLabel: 'Photo of ${itemTitle(item)}',
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(framed ? 20 : 0),
              child: SizedBox(
                height: heroHeight,
                child: GestureDetector(
                  onTap: photo == null
                      ? null
                      : () => openFullPhoto(context, session, item),
                  child: Semantics(
                    label: photo == null ? null : 'Open full photo',
                    button: photo != null,
                    child:
                        photo ??
                        ColoredBox(
                          color: c.surface2,
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: c.ink3,
                            semanticLabel: 'No photo',
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 37),
          ],
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                round(
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const Spacer(),
                round(_moreMenu(item)),
              ],
            ),
          ),
        ),
        Positioned(
          left: framed ? 0 : 16,
          right: framed ? 0 : 16,
          top: heroHeight - 19,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RefTag(item.refCode, large: true),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    textStyle: context.type.strong.copyWith(fontSize: 13.5),
                  ),
                  onPressed: () => _copy(item.refCode),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moreMenu(FoundItem item) => PopupMenuButton<String>(
    tooltip: 'More actions',
    icon: const Icon(Icons.more_vert),
    enabled: !_acting,
    onSelected: (value) => switch (value) {
      'recaption' => _recaption(),
      'dispose' => _disposeItem(),
      'transfer' => _transfer(),
      'edit' => _edit(item),
      _ => null,
    },
    itemBuilder: (_) => [
      if (item.status != ItemStatus.claimed)
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit details'),
          ),
        ),
      PopupMenuItem(
        value: 'recaption',
        enabled: item.status == ItemStatus.unclaimed && item.photoPath != null,
        child: const ListTile(
          leading: Icon(Icons.auto_awesome_outlined),
          title: Text('Recaption'),
        ),
      ),
      if (_canTransfer(item))
        const PopupMenuItem(
          value: 'transfer',
          child: ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Transfer'),
          ),
        ),
      if (item.status == ItemStatus.expired)
        const PopupMenuItem(
          value: 'dispose',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Dispose'),
          ),
        ),
    ],
  );

  bool _canTransfer(FoundItem item) => {
    ItemStatus.unclaimed,
    ItemStatus.matched,
    ItemStatus.expired,
  }.contains(item.status);

  List<Widget> _body(BuildContext context, FoundItem item) {
    final c = context.desk;
    final session = _session!;
    final reserved = _matches
        .where((m) => m.match.state == MatchState.confirmed)
        .firstOrNull;
    final pending = _matches
        .where((m) => m.match.state == MatchState.pending)
        .firstOrNull;
    final notices = itemNotices(item);
    const gap = SizedBox(height: 22);
    Widget? primary;
    if (item.status == ItemStatus.unclaimed ||
        (item.status == ItemStatus.matched && reserved != null)) {
      primary = FilledButton.icon(
        style: bigButtonStyle(context),
        onPressed: _acting ? null : () => _return(item),
        icon: const Icon(Icons.check, size: 20),
        label: const Text('Return to owner'),
      );
    } else if (item.status == ItemStatus.matched && pending != null) {
      primary = FilledButton.icon(
        style: bigButtonStyle(context),
        onPressed: () => openDeskScreen(
          context,
          session,
          MatchDetailScreen(
            matchId: pending.match.id!,
            reportId: pending.report.id!,
          ),
        ),
        icon: const Icon(Icons.compare_arrows, size: 20),
        label: const Text('Review proposed match'),
      );
    } else if (item.status == ItemStatus.expired) {
      primary = FilledButton.icon(
        style: bigButtonStyle(context),
        onPressed: _acting ? null : _disposeItem,
        icon: const Icon(Icons.delete_outline, size: 20),
        label: const Text('Dispose'),
      );
    }
    final tiles = <Widget>[
      TagButton(link: () => session.client.item.tagLink(item.id!), tile: true),
      if (_canTransfer(item))
        ActionTile(
          icon: Icons.swap_horiz,
          label: 'Transfer',
          onPressed: _acting ? null : _transfer,
        ),
      if (item.status != ItemStatus.claimed)
        ActionTile(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onPressed: _acting ? null : () => _edit(item),
        ),
    ];
    return [
      Text(itemTitle(item), style: context.type.headingAt(30, height: 1.1)),
      const SizedBox(height: 6),
      Text(
        itemSubtitle(item.attributes),
        style: context.type.body.copyWith(fontSize: 14.5, color: c.ink2),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          StatusChip(item.status),
          for (final (text, tone) in notices) StatusPill(text, tone: tone),
          if (item.restricted)
            const StatusPill('Staff only', icon: Icons.lock_outline),
        ],
      ),
      gap,
      if (_acting) ...[
        const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 10),
      ],
      ?primary,
      if (primary != null) const SizedBox(height: 10),
      Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
      gap,
      KvGrid([
        ('Found', dateTimeLabel(item.foundAt)),
        ('Zone', session.zoneName(item.zoneId)),
        ('Storage bin', item.storageBin ?? 'Not set'),
        ('Value', valueBandLabel(item.valueBand)),
        if (item.holdUntil != null) ('Hold until', shortDate(item.holdUntil!)),
        if (item.handoffDueAt != null)
          ('Hand to police by', shortDate(item.handoffDueAt!)),
      ]),
      const SizedBox(height: 12),
      LocationLine(events: _custody),
      if (item.status == ItemStatus.expired && _recommendation != null) ...[
        const SizedBox(height: 12),
        NoteStrip(
          icon: Icons.recommend_outlined,
          tone: DiscTone.tag,
          child: Text('Recommended: ${disposalLabel(_recommendation!)}'),
        ),
      ],
      if (_release != null) ...[
        gap,
        ReleaseReceipt(summary: _release!, showSignature: true),
      ],
      gap,
      if (item.attributes != null)
        AttributeChips(
          attributes: item.attributes!,
          restricted: item.restricted,
        )
      else ...[
        const SectionTitle('What the desk sees'),
        const SizedBox(height: 10),
        if (item.captionText != null)
          CopyableText(item.captionText!)
        else
          Text(
            item.status == ItemStatus.captioning
                ? 'Describing the photo. This usually takes under 15 seconds.'
                : 'No details yet. Edit the item to add them.',
            style: TextStyle(color: c.ink2),
          ),
      ],
      gap,
      DeskCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconDisc(Icons.lock_outline, size: 32, iconSize: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DeskLabel('Private notes · staff only'),
                  const SizedBox(height: 4),
                  Text(
                    item.privateNotes ?? 'No private notes',
                    style: TextStyle(
                      color: item.privateNotes == null ? c.ink3 : c.ink,
                    ),
                  ),
                  if (item.finderName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Finder: ${item.finderName}',
                      style: context.type.small.copyWith(color: c.ink2),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      gap,
      SectionTitle(
        'Possible owners',
        trailing: TitleNote(
          '${_matches.length} ${_matches.length == 1 ? 'report' : 'reports'}',
        ),
      ),
      const SizedBox(height: 10),
      MatchList(cards: _matches),
      gap,
      HistoryList(entries: _history),
    ];
  }
}
