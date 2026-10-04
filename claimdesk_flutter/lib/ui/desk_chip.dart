import 'package:flutter/material.dart';
import 'desk_theme.dart';

/// Pill-shaped filter chip. Selected chips fill with ink.
///
/// The pill is 36 px tall but the touch target is 48 px, the way Material
/// chips pad theirs. An active filter with [onDeleted] is removed by a tap
/// anywhere on the chip, which keeps one full-size target instead of a small
/// close button inside the pill.
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

  /// Makes the chip an active filter that a tap removes.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final foreground = selected ? c.inkOn : c.ink2;
    final action = onDeleted ?? onTap;
    return Semantics(
      container: true,
      button: true,
      selected: onDeleted == null && selected,
      enabled: action != null,
      label: onDeleted == null ? label : 'Remove filter $label',
      onTap: action,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: action,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Ink(
              height: 36,
              padding: EdgeInsets.only(
                left: 14,
                right: onDeleted == null ? 14 : 10,
              ),
              decoration: ShapeDecoration(
                color: selected ? c.ink : c.surface,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected ? c.ink : c.line,
                    width: 1.5,
                  ),
                ),
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
                  if (onDeleted != null) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.close, size: 16, color: foreground),
                  ],
                ],
              ),
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
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) => children[index],
    ),
  );
}
