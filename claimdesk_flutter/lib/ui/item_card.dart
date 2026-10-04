import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'status.dart';
import 'item_badges.dart';

String timeAgo(DateTime found, {DateTime? now}) {
  final age = (now ?? DateTime.now()).difference(found);
  if (age.inMinutes < 1) return 'just now';
  if (age.inHours < 1) return '${age.inMinutes} min ago';
  if (age.inDays < 1) return '${age.inHours} h ago';
  return '${age.inDays} d ago';
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.zoneName,
    this.photo,
    this.captionFailed = false,
    this.onTap,
    this.now,
  });
  final FoundItem item;
  final String zoneName;
  final Widget? photo;
  final bool captionFailed;
  final VoidCallback? onTap;
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    final warning =
        captionFailed ||
        (item.status == ItemStatus.captioning &&
            (now ?? DateTime.now()).difference(item.updatedAt).inSeconds >= 60);
    final title = item.attributes?.description.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 72,
                  child:
                      photo ??
                      const ColoredBox(
                        color: Color(0xffe8e8df),
                        child: Icon(
                          Icons.image_outlined,
                          color: Color(0xff52565b),
                          semanticLabel: 'No photo',
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title != null && title.isNotEmpty
                          ? title
                          : categoryLabel(item.attributes?.category ?? 'other'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('$zoneName · ${item.refCode}'),
                    Text('Found ${timeAgo(item.foundAt, now: now)}'),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(item.status),
                        if (item.restricted)
                          const Tooltip(
                            message: 'Restricted: staff only',
                            child: Icon(
                              Icons.lock_outline,
                              semanticLabel: 'Restricted',
                            ),
                          ),
                        if (warning)
                          const Icon(
                            Icons.warning_amber_rounded,
                            semanticLabel: 'Caption needs attention',
                          ),
                      ],
                    ),
                    if (warning)
                      Text(
                        captionFailed
                            ? 'Caption failed, tap to add details'
                            : 'Caption is taking longer. Tap to add details.',
                      ),
                    ItemBadges(item: item, now: now),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
