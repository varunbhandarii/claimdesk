import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../data/errors.dart';

String attentionLabel(String value) => switch (value) {
  'captioningFailed' => 'Captioning failed',
  'overdue' => 'Overdue hand-offs',
  'expiringSoon' => 'Expiring within three days',
  _ => value,
};

class DeskScreen extends StatelessWidget {
  const DeskScreen({
    super.key,
    required this.venueName,
    required this.summary,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onItems,
    required this.onInbox,
    required this.onReports,
    required this.onItem,
    this.matches = const [],
    this.reports = const [],
  });
  final String venueName;
  final DeskSummary? summary;
  final bool loading;
  final Object? error;
  final Future<void> Function() onRefresh;
  final void Function(String? attention, ItemStatus? status) onItems;
  final VoidCallback onInbox, onReports;
  final void Function(UuidValue) onItem;
  final List<MatchCard> matches;
  final List<LostReport> reports;

  @override
  Widget build(BuildContext context) {
    final data = summary;
    if (loading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, size) {
          final width = size.maxWidth > 1040 ? 1040.0 : size.maxWidth;
          final cardWidth = width >= 700 ? (width - 48) / 2 : width - 32;
          Widget card(
            String title,
            int count,
            VoidCallback open, {
            List<FoundItem> items = const [],
            DateTime? Function(FoundItem)? date,
            List<Widget> preview = const [],
            bool recent = false,
          }) => SizedBox(
            width: cardWidth,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: open,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                    if (count == 0) const Text('Nothing needs attention'),
                    for (final item in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          '${item.refCode} · ${item.captionText ?? item.attributes?.description ?? "Found item"}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: date?.call(item) == null
                            ? null
                            : Text(
                                date!(
                                  item,
                                )!.toLocal().toIso8601String().split('T').first,
                              ),
                        onTap: recent ? () => onItem(item.id!) : open,
                      ),
                    ...preview,
                    if (count > items.length && items.isNotEmpty)
                      Text('$count total, showing ${items.length}'),
                    TextButton(onPressed: open, child: const Text('See all')),
                  ],
                ),
              ),
            ),
          );
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: SizedBox(
                  width: width - 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (data != null)
                        Text(
                          'As of ${TimeOfDay.fromDateTime(data.generatedAt.toLocal()).format(context)} · ${data.onShelf} on shelf · ${data.returnedThisWeek} returned in seven days',
                        ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                      const SizedBox(height: 16),
                      if (data != null)
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            card(
                              'New matches to review',
                              data.newMatches,
                              onInbox,
                              preview: [
                                for (final match in matches.take(5))
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(
                                      '${match.report.refCode} · ${match.item.refCode}',
                                    ),
                                    onTap: onInbox,
                                  ),
                              ],
                            ),
                            card(
                              attentionLabel('captioningFailed'),
                              data.captioningFailedCount,
                              () => onItems('captioningFailed', null),
                              items: data.captioningFailed,
                            ),
                            card(
                              attentionLabel('overdue'),
                              data.overdueCount,
                              () => onItems('overdue', null),
                              items: data.overdue,
                              date: (i) => i.handoffDueAt,
                            ),
                            card(
                              attentionLabel('expiringSoon'),
                              data.expiringSoonCount,
                              () => onItems('expiringSoon', null),
                              items: data.expiringSoon,
                              date: (i) => i.holdUntil,
                            ),
                            card(
                              'Expired, awaiting disposal',
                              data.expiredCount,
                              () => onItems(null, ItemStatus.expired),
                              items: data.expired,
                              date: (i) => i.holdUntil,
                            ),
                            card(
                              'Open reports',
                              data.openReports,
                              onReports,
                              preview: [
                                for (final report
                                    in reports
                                        .where(
                                          (r) => {
                                            ReportStatus.received,
                                            ReportStatus.searching,
                                            ReportStatus.possibleMatch,
                                            ReportStatus.readyForPickup,
                                          }.contains(r.status),
                                        )
                                        .take(5))
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(report.refCode),
                                    onTap: onReports,
                                  ),
                              ],
                            ),
                            card(
                              'Last five items logged',
                              data.recent.length,
                              () => onItems(null, null),
                              items: data.recent,
                              date: (i) => i.createdAt,
                              recent: true,
                            ),
                          ],
                        ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
