import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'format.dart';

/// Surface card with a 1 px line and no shadow. Its border is painted
/// beneath the children so a Seam can bite notches out of the edges.
class DeskCard extends StatelessWidget {
  const DeskCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.radius = 16,
    this.color,
    this.selected = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final body = Padding(padding: padding, child: child);
    return Material(
      color: color ?? c.surface,
      borderOnForeground: selected,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: selected ? c.ink : c.line,
          width: selected ? 2 : 1,
        ),
      ),
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// Small caps label: "PRIVATE NOTES · STAFF ONLY".
class DeskLabel extends StatelessWidget {
  const DeskLabel(this.text, {super.key, this.colour});
  final String text;
  final Color? colour;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.type.label.copyWith(color: colour ?? context.desk.ink3),
  );
}

/// Page title with an optional quiet count on the right, as on Items or Inbox.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: context.type.displayAt(32)),
        ),
      ),
      if (trailing != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 12),
          child: Text(
            trailing!,
            style: context.type.body.copyWith(
              fontSize: 13,
              color: context.desk.ink3,
            ),
          ),
        ),
    ],
  );
}

/// Section heading with an optional trailing action or note.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.size = 20});
  final String title;
  final Widget? trailing;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: context.type.headingAt(size)),
        ),
      ),
      ?trailing,
    ],
  );
}

/// Quiet trailing note for a section title.
class TitleNote extends StatelessWidget {
  const TitleNote(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.type.small.copyWith(color: context.desk.ink3),
  );
}

enum DiscTone { ok, warn, bad, mute, tag, info }

/// Tinted circle holding an icon, used for evidence and section markers.
class IconDisc extends StatelessWidget {
  const IconDisc(
    this.icon, {
    super.key,
    this.tone = DiscTone.mute,
    this.size = 34,
    this.iconSize,
    this.text,
  });
  final IconData? icon;
  final DiscTone tone;
  final double size;
  final double? iconSize;
  final String? text;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (background, foreground) = switch (tone) {
      DiscTone.ok => (c.ok50, c.ok),
      DiscTone.warn => (c.warn50, c.warn),
      DiscTone.bad => (c.bad50, c.bad),
      DiscTone.mute => (c.surface2, c.ink3),
      DiscTone.tag => (c.tag50, c.tagInk),
      DiscTone.info => (c.ticket50, c.ticket),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: text != null
          ? Text(
              text!,
              style: context.type.strong.copyWith(
                fontSize: size * .62,
                height: 1,
                color: foreground,
              ),
            )
          : Icon(icon, size: iconSize ?? size * .55, color: foreground),
    );
  }
}

enum Evidence { agrees, differs, missing }

/// One line of match evidence: a check, a "≠" or a dash, then words.
class EvidenceLine extends StatelessWidget {
  const EvidenceLine(this.kind, this.text, {super.key, this.size = 20});
  final Evidence kind;
  final String text;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EvidenceMark(kind, size: size),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          style: context.type.body.copyWith(
            fontSize: 12.5,
            height: 1.3,
            color: context.desk.ink2,
          ),
        ),
      ),
    ],
  );
}

class EvidenceMark extends StatelessWidget {
  const EvidenceMark(this.kind, {super.key, this.size = 24});
  final Evidence kind;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: switch (kind) {
      Evidence.agrees => 'Agrees',
      Evidence.differs => 'Differs',
      Evidence.missing => 'No evidence',
    },
    child: switch (kind) {
      Evidence.agrees => IconDisc(Icons.check, tone: DiscTone.ok, size: size),
      Evidence.differs => IconDisc(
        null,
        tone: DiscTone.warn,
        size: size,
        text: '≠',
      ),
      Evidence.missing => IconDisc(
        Icons.remove,
        tone: DiscTone.mute,
        size: size,
      ),
    },
  );
}

/// Swatch colour for a stored colour value.
Decoration colourDecoration(String colour, {double radius = 999}) {
  const ring = Color(0x3816181B);
  final border = Border.all(color: ring);
  final shape = radius >= 999 ? BoxShape.circle : BoxShape.rectangle;
  final r = shape == BoxShape.circle ? null : BorderRadius.circular(radius);
  return switch (colour) {
    'silver' => BoxDecoration(
      shape: shape,
      borderRadius: r,
      border: border,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6E8EB), Color(0xFFA9AEB5)],
      ),
    ),
    'multicolour' => BoxDecoration(
      shape: shape,
      borderRadius: r,
      border: border,
      gradient: const SweepGradient(
        colors: [
          Color(0xFFC8322B),
          Color(0xFFF2CC3A),
          Color(0xFF3F8F4E),
          Color(0xFF2F6FD6),
          Color(0xFF7B4BB0),
          Color(0xFFC8322B),
        ],
      ),
    ),
    'transparent' => BoxDecoration(
      shape: shape,
      borderRadius: r,
      border: border,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, .5, .5, 1],
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
          Color(0xFFE9E8E3),
          Color(0xFFE9E8E3),
        ],
      ),
    ),
    _ => BoxDecoration(
      shape: shape,
      borderRadius: r,
      border: border,
      color: switch (colour) {
        'black' => const Color(0xFF17181A),
        'white' => const Color(0xFFFFFFFF),
        'grey' => const Color(0xFF8C8F94),
        'gold' => const Color(0xFFC9A23A),
        'red' => const Color(0xFFC8322B),
        'orange' => const Color(0xFFE8792B),
        'yellow' => const Color(0xFFF2CC3A),
        'green' => const Color(0xFF3F8F4E),
        'blue' => const Color(0xFF2F6FD6),
        'navy' => const Color(0xFF1F2D5A),
        'purple' => const Color(0xFF7B4BB0),
        'pink' => const Color(0xFFE58FB0),
        'brown' => const Color(0xFF7A4A24),
        'beige' => const Color(0xFFD9C6A3),
        _ => const Color(0xFFB9B7B0),
      },
    ),
  };
}

class ColourDot extends StatelessWidget {
  const ColourDot(this.colour, {super.key, this.size = 12});
  final String colour;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: colourLabel(colour),
    child: Container(
      width: size,
      height: size,
      decoration: colourDecoration(colour),
    ),
  );
}

/// Colour dots with their names, as in "● Black  ● Brown".
class ColourNames extends StatelessWidget {
  const ColourNames(this.colours, {super.key, this.extra = const []});
  final List<String> colours;
  final List<String> extra;
  @override
  Widget build(BuildContext context) {
    final style = context.type.body.copyWith(
      fontSize: 14,
      color: context.desk.ink2,
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final colour in colours)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: ColourDot(colour)),
              const SizedBox(width: 6),
              Text(colourLabel(colour), style: style),
            ],
          ),
        for (final text in extra) Text(text, style: style),
      ],
    );
  }
}

/// Two-column facts grid separated by hairlines.
class KvGrid extends StatelessWidget {
  const KvGrid(this.entries, {super.key});
  final List<(String, String)> entries;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      Widget cell((String, String)? entry) => Expanded(
        child: Container(
          color: c.surface,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: entry == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeskLabel(entry.$1),
                    const SizedBox(height: 4),
                    Text(
                      entry.$2,
                      style: context.type.strong.copyWith(fontSize: 15),
                    ),
                  ],
                ),
        ),
      );
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cell(entries[i]),
              Container(width: 1, color: c.line),
              cell(i + 1 < entries.length ? entries[i + 1] : null),
            ],
          ),
        ),
      );
      if (i + 2 < entries.length) rows.add(Container(height: 1, color: c.line));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(children: rows),
      ),
    );
  }
}

/// Bottom action bar that stays put while the page scrolls.
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child, this.note});
  final Widget child;
  final String? note;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  if (note != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      note!,
                      textAlign: TextAlign.center,
                      style: context.type.small.copyWith(color: c.ink3),
                    ),
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

/// Field with its label above it, as in the design's forms.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });
  final String label;
  final String? hint;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: context.type.strong.copyWith(fontSize: 14)),
      if (hint != null) ...[
        const SizedBox(height: 3),
        Text(
          hint!,
          style: context.type.small.copyWith(color: context.desk.ink3),
        ),
      ],
      const SizedBox(height: 7),
      child,
    ],
  );
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final letters = parts.length == 1
      ? parts.first.substring(0, math.min(2, parts.first.length))
      : '${parts.first[0]}${parts.last[0]}';
  return letters.toUpperCase();
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 36});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.ink, shape: BoxShape.circle),
      child: Text(
        initials(name),
        style: context.type.strong.copyWith(
          fontSize: size * .36,
          height: 1,
          color: c.inkOn,
        ),
      ),
    );
  }
}

/// Count tile on the Desk: big mono number, quiet label.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
    this.large = false,
  });
  final int value;
  final String label;
  final VoidCallback? onTap;
  final bool large;
  @override
  Widget build(BuildContext context) => DeskCard(
    radius: 14,
    onTap: onTap,
    padding: large
        ? const EdgeInsets.fromLTRB(18, 16, 18, 16)
        : const EdgeInsets.fromLTRB(12, 12, 12, 10),
    child: Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: context.type.mono.copyWith(
              fontSize: large ? 30 : 24,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.body.copyWith(
              fontSize: large ? 13.5 : 12.5,
              height: 1.25,
              color: context.desk.ink3,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Score bar with the possible and strong thresholds marked.
class ScoreMeter extends StatelessWidget {
  const ScoreMeter({super.key, required this.score});
  final double score;
  static const possibleFrom = .45, strongFrom = .70;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final value = score.clamp(0.0, 1.0);
    final fill = value >= strongFrom
        ? c.ok
        : value >= possibleFrom
        ? c.warn
        : c.ink3;
    return Semantics(
      label:
          'Score ${score.toStringAsFixed(2)}; possible from 0.45, strong from 0.70',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 16,
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 4,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 4,
                    height: 8,
                    width: box.maxWidth * value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  for (final mark in [possibleFrom, strongFrom])
                    Positioned(
                      left: box.maxWidth * mark - 1,
                      top: 0,
                      width: 2,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.ink3,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Possible from 0.45', style: _note(context)),
              Text('Strong from 0.70', style: _note(context)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _note(BuildContext context) =>
      context.type.body.copyWith(fontSize: 12, color: context.desk.ink3);
}

/// Numbered step marker for multi-part forms.
class StepNumber extends StatelessWidget {
  const StepNumber(this.number, {super.key});
  final int number;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.ink, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: context.type.mono.copyWith(
          fontSize: 13,
          height: 1,
          color: c.inkOn,
        ),
      ),
    );
  }
}

/// Rounded thumbnail frame; shows a quiet placeholder when there is no photo.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    this.photo,
    this.size = 52,
    this.radius = 12,
    this.locked = false,
  });
  final Widget? photo;
  final double size, radius;
  final bool locked;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child:
            photo ??
            ColoredBox(
              color: c.surface2,
              child: Icon(
                locked ? Icons.lock_outline : Icons.image_outlined,
                size: size * .4,
                color: c.ink3,
                semanticLabel: locked ? 'Restricted item' : 'No photo',
              ),
            ),
      ),
    );
  }
}

/// Orange call-to-action style, used for logging a found item.
ButtonStyle tagButtonStyle(BuildContext context) {
  final c = context.desk;
  return FilledButton.styleFrom(
    backgroundColor: c.tag,
    foregroundColor: c.tagOn,
  );
}

/// Bigger primary action, 54 px tall.
ButtonStyle bigButtonStyle(BuildContext context) => FilledButton.styleFrom(
  minimumSize: const Size(48, 54),
  textStyle: context.type.strong.copyWith(fontSize: 16),
);

/// Message with a retry action, used when a list or page fails to load.
class RetryMessage extends StatelessWidget {
  const RetryMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconDisc(Icons.wifi_off, tone: DiscTone.warn, size: 48),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

/// Inline tinted note with an icon, such as the private-link reminder.
class NoteStrip extends StatelessWidget {
  const NoteStrip({
    super.key,
    required this.icon,
    required this.child,
    this.tone = DiscTone.mute,
  });
  final IconData icon;
  final Widget child;
  final DiscTone tone;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (background, foreground) = switch (tone) {
      DiscTone.ok => (c.ok50, c.ok),
      DiscTone.warn => (c.warn50, c.warn),
      DiscTone.bad => (c.bad50, c.bad),
      DiscTone.tag => (c.tag50, c.tagInk),
      DiscTone.info => (c.ticket50, c.ticket),
      DiscTone.mute => (c.surface2, c.ink2),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: context.type.body.copyWith(fontSize: 14, color: c.ink),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
