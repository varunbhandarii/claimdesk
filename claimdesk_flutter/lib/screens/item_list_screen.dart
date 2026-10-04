import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/app_entry.dart';
import '../data/errors.dart';
import '../ui/brand.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/desk_menu.dart';
import '../ui/export_sheet.dart';
import '../ui/offline_banner.dart';
import '../ui/photo_view.dart';
import 'desk_screen.dart';
import 'inbox_screen.dart';
import 'item_detail_screen.dart';
import 'items_tab.dart';
import 'log_item_screen.dart';
import 'match_detail_screen.dart';
import 'report_list_screen.dart';

/// Signed-in shell: Desk, Items, Reports and Inbox. Phones get a header and a
/// bottom bar; wide windows get a side rail.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({
    super.key,
    required this.onSignOut,
    required this.onChangeVenue,
  });
  final Future<void> Function() onSignOut;
  final VoidCallback onChangeVenue;
  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  static const wideFrom = 1000.0;
  Timer? _clock;
  int _tab = 0;
  VenueSession? _session;
  DeskEvent? _lastEvent;
  Object? _lastError;
  String? _entry = itemEntry(Uri.base);
  bool _openingEntry = false;
  final _searchFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = VenueScope.of(context);
    if (_session != session) {
      _session?.removeListener(_changed);
      _session = session;
      session.addListener(_changed);
      _openEntry();
    }
  }

  Future<void> _openEntry() async {
    final reference = _entry;
    if (reference == null || _openingEntry) return;
    _openingEntry = true;
    try {
      final exact = await _session!.client.item.findByRefCode(
        _session!.venue.id!,
        reference,
      );
      _entry = null;
      if (mounted) {
        if (exact != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openItem(exact.id!);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This reference is not available in your selected venue.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    } finally {
      _openingEntry = false;
    }
  }

  Future<void> _export() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ExportSheet(
      export: (kind) =>
          _session!.client.export.export(_session!.venue.id!, kind),
    ),
  );

  void _changed() {
    final session = _session!;
    final event = session.lastEvent;
    if (event != null && !identical(event, _lastEvent)) {
      _lastEvent = event;
      if (event.kind == 'captionFailed') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Caption failed. Add details or try again.'),
              action: event.itemId == null
                  ? null
                  : SnackBarAction(
                      label: 'Open item',
                      onPressed: () => _openItem(event.itemId!),
                    ),
            ),
          );
        });
      }
    }
    if (session.error != null && !identical(session.error, _lastError)) {
      final error = session.error!;
      _lastError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage(error))));
        }
      });
    }
  }

  Future<void> _openItem(UuidValue id) async {
    await openDeskScreen(context, _session!, ItemDetailScreen(itemId: id));
    if (mounted) unawaited(_session!.refreshItems());
  }

  Future<void> _log() async {
    await openDeskScreen(context, _session!, const LogItemScreen());
    if (mounted) await _session!.refreshItems();
  }

  void _search() {
    setState(() => _tab = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _menu(String value) {
    if (value == 'out') {
      widget.onSignOut();
    } else if (value == 'export') {
      _export();
    } else if (value == 'poster') {
      showPosterDialog(
        context,
        () => _session!.client.venue.posterLink(_session!.venue.id!),
      );
    } else {
      widget.onChangeVenue();
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    _searchFocus.dispose();
    _session?.removeListener(_changed);
    super.dispose();
  }

  Widget? _thumb(VenueSession session, FoundItem item) => item.photoPath == null
      ? null
      : PhotoView(
          urls: session.photos,
          itemId: item.id!,
          thumb: true,
          revision: item.thumbPath,
          onDenied: session.onDenied,
        );

  Widget _content(VenueSession session, bool wide) => switch (_tab) {
    0 => DeskScreen(
      summary: session.summary,
      loading: session.summaryLoading,
      error: session.summaryError,
      onRefresh: session.refreshSummary,
      matches: session.inbox,
      photoFor: (item) => _thumb(session, item),
      zoneName: session.zoneName,
      onItems: (attention, status) {
        session.presetItems(attention, status);
        setState(() => _tab = 1);
      },
      onInbox: () => setState(() => _tab = 3),
      onMatch: (card) => openDeskScreen(
        context,
        session,
        MatchDetailScreen(matchId: card.match.id!, reportId: card.report.id!),
      ),
      onReports: () {
        session.reportStatusFilter = null;
        session.reportZoneFilter = null;
        session.reportCategoryFilter = null;
        session.refreshReports();
        setState(() => _tab = 2);
      },
      onItem: _openItem,
      onExport: canExport(session.membership) ? _export : null,
    ),
    1 => ItemsTab(
      onOpenItem: _openItem,
      onLog: _log,
      searchFocus: _searchFocus,
      wide: wide,
    ),
    2 => ReportListScreen(wide: wide),
    _ => InboxScreen(wide: wide),
  };

  void _retry(VenueSession session) {
    session.live.connectivityChanged(true);
    switch (_tab) {
      case 0:
        session.refreshSummary();
      case 1:
        session.refreshItems();
      case 2:
        session.refreshReports();
      default:
        session.refreshInbox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= wideFrom;
        final offline = session.offline || session.live.reconnecting;
        final body = Column(
          children: [
            if (offline) OfflineBanner(onRetry: () => _retry(session)),
            Expanded(child: _content(session, wide)),
          ],
        );
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                _DeskRail(
                  session: session,
                  tab: _tab,
                  onTab: (tab) => setState(() => _tab = tab),
                  onLog: _log,
                  onMenu: _menu,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _PhoneHeader(
                  session: session,
                  onSearch: _search,
                  onMenu: _menu,
                ),
                Expanded(child: body),
              ],
            ),
          ),
          floatingActionButton: _tab > 1
              ? null
              : FloatingActionButton.extended(
                  onPressed: _log,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Log item'),
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Desk',
              ),
              const NavigationDestination(
                icon: Icon(Icons.sell_outlined),
                selectedIcon: Icon(Icons.sell),
                label: 'Items',
              ),
              const NavigationDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: session.inbox.isNotEmpty,
                  label: Text('${session.inbox.length}'),
                  child: const Icon(Icons.inbox_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: session.inbox.isNotEmpty,
                  label: Text('${session.inbox.length}'),
                  child: const Icon(Icons.inbox),
                ),
                label: 'Inbox',
              ),
            ],
          ),
        );
      },
    );
  }
}

String _roleLabel(StaffMembership membership) =>
    membership.role == StaffRole.supervisor ? 'Supervisor' : 'Staff';

class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({
    required this.session,
    required this.onSearch,
    required this.onMenu,
  });
  final VenueSession session;
  final VoidCallback onSearch;
  final ValueChanged<String> onMenu;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            const ClaimDeskMark(width: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.headingAt(16.5, height: 1.15),
                  ),
                  Text(
                    '${session.membership.displayName} · ${_roleLabel(session.membership)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.body.copyWith(
                      fontSize: 12,
                      color: c.ink3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Search items',
              onPressed: onSearch,
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              tooltip: 'Desk options',
              onSelected: onMenu,
              itemBuilder: (_) => deskMenuItems(session.membership),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Avatar(session.membership.displayName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeskRail extends StatelessWidget {
  const _DeskRail({
    required this.session,
    required this.tab,
    required this.onTab,
    required this.onLog,
    required this.onMenu,
  });
  final VenueSession session;
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onLog;
  final ValueChanged<String> onMenu;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final summary = session.summary;
    Widget count(int? value) => value == null
        ? const SizedBox.shrink()
        : Text(
            '$value',
            style: context.type.mono.copyWith(fontSize: 12.5, color: c.ink3),
          );
    final destinations = [
      (Icons.space_dashboard_outlined, 'Desk', const SizedBox.shrink()),
      (Icons.sell_outlined, 'Items', count(summary?.onShelf)),
      (
        Icons.confirmation_number_outlined,
        'Reports',
        count(summary?.openReports),
      ),
      (
        Icons.inbox_outlined,
        'Inbox',
        session.inbox.isEmpty
            ? const SizedBox.shrink()
            : Badge(
                label: Text('${session.inbox.length}'),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
      ),
    ];
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.line)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DeskWordmark(size: 21),
              ),
            ),
            Tooltip(
              message: 'Change venue',
              child: Material(
                color: c.paper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: c.line, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onMenu('venue'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.type.strong.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Change venue',
                                style: context.type.body.copyWith(
                                  fontSize: 12,
                                  color: c.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.unfold_more, size: 18, color: c.ink2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: tagButtonStyle(context),
              onPressed: onLog,
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: const Text('Log item'),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < destinations.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Semantics(
                  selected: tab == i,
                  button: true,
                  child: Material(
                    color: tab == i ? c.tag50 : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onTab(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            Icon(destinations[i].$1, size: 20, color: c.ink),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                destinations[i].$2,
                                style: context.type.strong.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            destinations[i].$3,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 0, 0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: Row(
                children: [
                  Avatar(session.membership.displayName),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.membership.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.strong.copyWith(fontSize: 14),
                        ),
                        Text(
                          _roleLabel(session.membership),
                          style: context.type.body.copyWith(
                            fontSize: 12,
                            color: c.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Desk options',
                    icon: const Icon(Icons.more_vert),
                    onSelected: onMenu,
                    itemBuilder: (_) => deskMenuItems(session.membership),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
