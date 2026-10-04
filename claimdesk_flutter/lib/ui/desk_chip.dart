import 'package:flutter/material.dart';
import 'desk_theme.dart';

/// Pill-shaped filter chip. Selected chips fill with ink.
class DeskChip extends StatelessWidget {
  const DeskChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.onDeleted,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Shows a remove button for an active filter.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final foreground = selected ? c.inkOn : c.ink2;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.ink : c.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? c.ink : c.line, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: EdgeInsets.only(
              left: 14,
              right: onDeleted == null ? 14 : 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.type.strong.copyWith(
                    fontSize: 13.5,
                    height: 1,
                    color: foreground,
                  ),
                ),
                if (onDeleted != null)
                  IconButton(
                    tooltip: 'Remove filter $label',
                    onPressed: onDeleted,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(Icons.close, size: 16, color: foreground),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of chips with the page's side padding.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children, this.padding = 16});
  final List<Widget> children;
  final double padding;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) => children[index],
    ),
  );
}
