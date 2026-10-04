import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'item_badges.dart';
import 'pills.dart';
import 'status.dart';

/// Grid card for a found item: photo with its tag, a short name, where and
/// how long ago, then its status.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.zoneName,
    this.photo,
    this.captionFailed = false,
    this.onTap,
    this.now,
    this.photoHeight = 146,
  });
  final FoundItem item;
  final String zoneName;
  final Widget? photo;
  final bool captionFailed;
  final VoidCallback? onTap;
  final DateTime? now;
  final double photoHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final warning =
        captionFailed ||
        (item.status == ItemStatus.captioning &&
            (now ?? DateTime.now()).difference(item.updatedAt).inSeconds >= 60);
    final notices = itemNotices(item, now: now, compact: true);
    return DeskCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: photoHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                photo ??
                    ColoredBox(
                      color: c.surface2,
                      child: Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: c.ink3,
                        semanticLabel: 'No photo',
                      ),
                    ),
                Positioned(left: 8, bottom: 8, child: RefTag(item.refCode)),
                if (item.restricted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Tooltip(
                      message: 'Restricted: staff only',
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c.surface.withValues(alpha: .94),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 17,
                          color: c.ink,
                          semanticLabel: 'Restricted',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemTitle(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.strong.copyWith(
                    fontSize: 14.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$zoneName · ${ageShort(item.foundAt, now: now)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.small.copyWith(color: c.ink3),
                ),
                if (warning) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: c.warn,
                        semanticLabel: 'Caption needs attention',
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          captionFailed
                              ? 'Caption failed, tap to add details'
                              : 'Caption is taking longer. Tap to add details.',
                          style: context.type.small.copyWith(
                            color: c.warn,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusChip(item.status),
                    for (final (text, tone) in notices)
                      StatusPill(text, tone: tone),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays cards out in equal columns; each row is as tall as its tallest card.
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minCardWidth = 168,
    this.spacing = 12,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.header = const [],
    this.footer = const [],
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minCardWidth, spacing;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final List<Widget> header, footer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = box.maxWidth - padding.horizontal;
      final columns = ((width + spacing) / (minCardWidth + spacing))
          .floor()
          .clamp(1, 6);
      final rows = (itemCount / columns).ceil();
      return ListView.builder(
        physics: physics,
        padding: padding,
        itemCount: header.length + rows + footer.length,
        itemBuilder: (context, index) {
          if (index < header.length) return header[index];
          final row = index - header.length;
          if (row >= rows) return footer[row - rows];
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var column = 0; column < columns; column++) ...[
                    if (column > 0) SizedBox(width: spacing),
                    Expanded(
                      child: row * columns + column < itemCount
                          ? itemBuilder(context, row * columns + column)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
