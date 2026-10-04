import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/categories.dart';
import '../ui/desk_chip.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/empty_state.dart';
import '../ui/item_card.dart';
import '../ui/item_search_field.dart';
import '../ui/photo_view.dart';
import '../ui/status.dart';
import 'desk_screen.dart';

const _quickStatuses = [
  null,
  ItemStatus.unclaimed,
  ItemStatus.matched,
  ItemStatus.expired,
  ItemStatus.captioning,
  ItemStatus.claimed,
  ItemStatus.transferred,
  ItemStatus.disposed,
];

/// Every found item at the desk, searchable and filterable, as a photo grid.
class ItemsTab extends StatelessWidget {
  const ItemsTab({
    super.key,
    required this.onOpenItem,
    required this.onLog,
    this.searchFocus,
    this.wide = false,
  });
  final void Function(UuidValue id) onOpenItem;
  final VoidCallback onLog;
  final FocusNode? searchFocus;
  final bool wide;

  Future<void> _filters(BuildContext context, VenueSession session) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => VenueScope(
          session: session,
          child: const _FiltersSheet(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    final c = context.desk;
    final side = wide ? 32.0 : 16.0;
    final filters = [
      session.zoneFilter,
      session.categoryFilter,
    ].where((f) => f != null).length;
    final onShelf = session.summary?.onShelf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(side, wide ? 26 : 4, side, 12),
          child: PageTitle(
            'Items',
            trailing: onShelf == null
                ? '${session.items.length} in this view'
                : '$onShelf on shelf',
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: side),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wide ? 520 : double.infinity,
              ),
              child: ItemSearchField(
                query: session.searchQuery,
                onQuery: session.search,
                results: session.items.length,
                focusNode: searchFocus,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ChipRow(
          padding: side,
          children: [
            DeskChip(
              label: filters == 0 ? 'Filters' : 'Filters · $filters',
              icon: Icons.tune,
              selected: false,
              onTap: () => _filters(context, session),
            ),
            for (final status in _quickStatuses)
              DeskChip(
                label: status == null ? 'All open' : statusLabel(status),
                selected:
                    session.statusFilter == status &&
                    session.attentionFilter == null,
                onTap: () {
                  session.statusFilter = status;
                  session.attentionFilter = null;
                  session.refreshItems();
                },
              ),
          ],
        ),
        if (session.attentionFilter != null ||
            session.zoneFilter != null ||
            session.categoryFilter != null)
          Padding(
            padding: EdgeInsets.fromLTRB(side, 6, side, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (session.attentionFilter != null)
                  DeskChip(
                    label: attentionLabel(session.attentionFilter!),
                    selected: true,
                    onTap: null,
                    onDeleted: () {
                      session.attentionFilter = null;
                      session.refreshItems();
                    },
                  ),
                if (session.zoneFilter != null)
                  DeskChip(
                    label: session.zoneName(session.zoneFilter),
                    icon: Icons.place_outlined,
                    selected: true,
                    onTap: null,
                    onDeleted: () {
                      session.zoneFilter = null;
                      session.refreshItems();
                    },
                  ),
                if (session.categoryFilter != null)
                  DeskChip(
                    label: session.categoryFilter!,
                    selected: true,
                    onTap: null,
                    onDeleted: () {
                      session.categoryFilter = null;
                      session.refreshItems();
                    },
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 2,
          child: session.refreshing && !session.loading
              ? const LinearProgressIndicator(minHeight: 2)
              : null,
        ),
        Expanded(
          child: session.loading
              ? CardGrid(
                  itemCount: 6,
                  minCardWidth: wide ? 220 : 160,
                  padding: EdgeInsets.fromLTRB(side, 6, side, 110),
                  itemBuilder: (_, _) => Container(
                    height: 230,
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: session.refreshItems,
                  child: session.error != null && session.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            RetryMessage(
                              message: errorMessage(session.error!),
                              onRetry: session.refreshItems,
                            ),
                          ],
                        )
                      : session.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [EmptyState(onLog: onLog)],
                        )
                      : CardGrid(
                          physics: const AlwaysScrollableScrollPhysics(),
                          minCardWidth: wide ? 220 : 160,
                          padding: EdgeInsets.fromLTRB(side, 6, side, 110),
                          itemCount: session.items.length,
                          itemBuilder: (context, index) {
                            final item = session.items[index];
                            return ItemCard(
                              key: ValueKey('${item.id}/${item.updatedAt}'),
                              item: item,
                              zoneName: session.zoneName(item.zoneId),
                              captionFailed:
                                  session.failedItems.contains(item.id) ||
                                  (item.photoPath != null &&
                                      item.attributes?.modelId == 'template'),
                              photo: item.photoPath == null
                                  ? null
                                  : PhotoView(
                                      urls: session.photos,
                                      itemId: item.id!,
                                      thumb: true,
                                      revision: item.thumbPath,
                                      onDenied: session.onDenied,
                                    ),
                              onTap: () => onOpenItem(item.id!),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet();
  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    void apply(VoidCallback change) {
      change();
      session.refreshItems();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: context.type.headingAt(22)),
            const SizedBox(height: 18),
            const DeskLabel('Zone'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DeskChip(
                  label: 'All zones',
                  selected: session.zoneFilter == null,
                  onTap: () => apply(() => session.zoneFilter = null),
                ),
                for (final zone in session.zones)
                  DeskChip(
                    label: zone.name,
                    selected: session.zoneFilter == zone.id,
                    onTap: () => apply(() => session.zoneFilter = zone.id),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const DeskLabel('Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DeskChip(
                  label: 'All categories',
                  selected: session.categoryFilter == null,
                  onTap: () => apply(() => session.categoryFilter = null),
                ),
                for (final group in categories.values.toSet())
                  DeskChip(
                    label: group,
                    selected: session.categoryFilter == group,
                    onTap: () => apply(() => session.categoryFilter = group),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Show items'),
            ),
          ],
        ),
      ),
    );
  }
}
