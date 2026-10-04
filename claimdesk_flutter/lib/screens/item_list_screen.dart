import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/status.dart';
import '../ui/item_card.dart';
import '../ui/photo_view.dart';
import '../ui/offline_banner.dart';
import '../ui/empty_state.dart';
import '../ui/item_search_field.dart';
import '../ui/categories.dart';
import 'log_item_screen.dart';
import 'item_detail_screen.dart';
import 'report_list_screen.dart';
import 'inbox_screen.dart';
import 'desk_screen.dart';

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
  Timer? _clock;
  int _tab = 0;
  VenueSession? _session;
  DeskEvent? _lastEvent;
  Object? _lastError;
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
    }
  }

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

  @override
  void dispose() {
    _clock?.cancel();
    _session?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClaimDesk'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Desk options',
            onSelected: (value) {
              if (value == 'out') {
                widget.onSignOut();
              } else {
                widget.onChangeVenue();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'venue', child: Text('Change venue')),
              const PopupMenuItem(value: 'out', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Desk',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Items',
          ),
          const NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: session.inbox.isNotEmpty,
              label: Text('${session.inbox.length}'),
              child: const Icon(Icons.inbox_outlined),
            ),
            label: 'Inbox',
          ),
        ],
      ),
      floatingActionButton: _tab > 1
          ? null
          : FloatingActionButton.extended(
              onPressed: _log,
              icon: const Icon(Icons.add),
              label: const Text('Log item'),
            ),
      body: _tab == 0
          ? Column(
              children: [
                if (session.offline || session.live.reconnecting)
                  OfflineBanner(
                    onRetry: () {
                      session.live.connectivityChanged(true);
                      session.refreshSummary();
                    },
                  ),
                Expanded(
                  child: DeskScreen(
                    venueName: session.venue.name,
                    summary: session.summary,
                    loading: session.summaryLoading,
                    error: session.summaryError,
                    onRefresh: session.refreshSummary,
                    matches: session.inbox,
                    reports: session.reports,
                    onItems: (attention, status) {
                      session.presetItems(attention, status);
                      setState(() => _tab = 1);
                    },
                    onInbox: () => setState(() => _tab = 3),
                    onReports: () {
                      session.reportStatusFilter = null;
                      session.reportZoneFilter = null;
                      session.reportCategoryFilter = null;
                      session.refreshReports();
                      setState(() => _tab = 2);
                    },
                    onItem: _openItem,
                  ),
                ),
              ],
            )
          : _tab == 3
          ? const InboxScreen()
          : _tab == 2
          ? const ReportListScreen()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  children: [
                    if (session.offline || session.live.reconnecting)
                      OfflineBanner(
                        onRetry: () {
                          session.live.connectivityChanged(true);
                          session.refreshItems();
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.venue.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session.membership.role == StaffRole.supervisor ? 'Supervisor' : 'Staff'} · ${session.items.length} items in this view',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Filter by zone',
                            onSelected: (id) {
                              session.zoneFilter = id.isEmpty
                                  ? null
                                  : UuidValue.fromString(id);
                              session.refreshItems();
                            },
                            icon: const Icon(Icons.filter_alt_outlined),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: '',
                                child: Text('All zones'),
                              ),
                              for (final zone in session.zones)
                                PopupMenuItem(
                                  value: zone.id.toString(),
                                  child: Text(zone.name),
                                ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Filter by category',
                            icon: const Icon(Icons.category_outlined),
                            onSelected: (value) {
                              session.categoryFilter = value.isEmpty
                                  ? null
                                  : value;
                              session.refreshItems();
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: '',
                                child: Text('All categories'),
                              ),
                              for (final entry in categories.entries)
                                PopupMenuItem(
                                  value: entry.value,
                                  child: Text(entry.value),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ItemSearchField(
                        query: session.searchQuery,
                        onQuery: session.search,
                        results: session.items.length,
                      ),
                    ),
                    if (session.categoryFilter != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: InputChip(
                            label: Text(session.categoryFilter!),
                            onDeleted: () {
                              session.categoryFilter = null;
                              session.refreshItems();
                            },
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          for (final status in [
                            null,
                            ItemStatus.captioning,
                            ItemStatus.unclaimed,
                            ItemStatus.matched,
                            ItemStatus.claimed,
                            ItemStatus.expired,
                            ItemStatus.transferred,
                            ItemStatus.disposed,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  status == null
                                      ? 'All open'
                                      : statusLabel(status),
                                ),
                                selected: session.statusFilter == status,
                                onSelected: (_) {
                                  session.statusFilter = status;
                                  session.refreshItems();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (session.zoneFilter != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Zone: ${session.zoneName(session.zoneFilter)}',
                        ),
                      ),
                    if (session.attentionFilter != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InputChip(
                            label: Text(
                              attentionLabel(session.attentionFilter!),
                            ),
                            onDeleted: () {
                              session.attentionFilter = null;
                              session.refreshItems();
                            },
                          ),
                        ),
                      ),
                    if (session.refreshing && !session.loading)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: session.loading
                          ? ListView(
                              children: List.generate(
                                4,
                                (_) => const Card(
                                  child: SizedBox(
                                    height: 110,
                                    child: Center(
                                      child: LinearProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: session.refreshItems,
                              child:
                                  session.error != null && session.items.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            children: [
                                              Text(
                                                errorMessage(session.error!),
                                              ),
                                              const SizedBox(height: 16),
                                              FilledButton(
                                                onPressed: session.refreshItems,
                                                child: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : session.items.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [EmptyState(onLog: _log)],
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        100,
                                      ),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: session.items.length,
                                      itemBuilder: (context, index) {
                                        final item = session.items[index];
                                        return AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: ItemCard(
                                            key: ValueKey(
                                              '${item.id}/${item.updatedAt}',
                                            ),
                                            item: item,
                                            zoneName: session.zoneName(
                                              item.zoneId,
                                            ),
                                            captionFailed:
                                                session.failedItems.contains(
                                                  item.id,
                                                ) ||
                                                (item.photoPath != null &&
                                                    item.attributes?.modelId ==
                                                        'template'),
                                            photo: item.photoPath == null
                                                ? null
                                                : PhotoView(
                                                    urls: session.photos,
                                                    itemId: item.id!,
                                                    thumb: true,
                                                    revision: item.thumbPath,
                                                    onDenied: session.onDenied,
                                                  ),
                                            onTap: () => _openItem(item.id!),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
