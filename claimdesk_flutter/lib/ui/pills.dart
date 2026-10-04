import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';

enum Tone { ok, warn, bad, info, mute, tag, draft }

/// Status pill: a dot and a word. Colour never carries the meaning alone.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone = Tone.mute, this.icon});
  final String label;
  final Tone tone;
  final IconData? icon;

  static (Color background, Color foreground) colours(
    DeskColors c,
    Tone tone,
  ) => switch (tone) {
    Tone.ok => (c.ok50, c.ok),
    Tone.warn => (c.warn50, c.warn),
    Tone.bad => (c.bad50, c.bad),
    Tone.info => (c.ticket50, c.ticket),
    Tone.mute => (c.surface2, c.ink2),
    Tone.tag => (c.tag50, c.tagInk),
    Tone.draft => (const Color(0x00000000), c.ink2),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (background, foreground) = colours(c, tone);
    final draft = tone == Tone.draft;
    return Container(
      height: 24,
      padding: const EdgeInsets.only(left: 8, right: 10),
      decoration: ShapeDecoration(
        color: background,
        shape: StadiumBorder(
          side: draft ? BorderSide(color: c.line, width: 1.5) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: foreground)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: draft ? null : foreground,
                border: draft
                    ? Border.all(color: foreground, width: 1.5)
                    : null,
              ),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.strong.copyWith(
                fontSize: 12.5,
                height: 1,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Tone itemTone(ItemStatus status) => switch (status) {
  ItemStatus.intake || ItemStatus.captioning => Tone.info,
  ItemStatus.unclaimed => Tone.mute,
  ItemStatus.matched => Tone.tag,
  ItemStatus.claimed => Tone.ok,
  ItemStatus.transferred || ItemStatus.disposed => Tone.mute,
  ItemStatus.expired => Tone.warn,
};

Tone reportTone(ReportStatus status) => switch (status) {
  ReportStatus.received => Tone.mute,
  ReportStatus.searching => Tone.info,
  ReportStatus.possibleMatch => Tone.warn,
  ReportStatus.readyForPickup || ReportStatus.returned => Tone.ok,
  ReportStatus.closed => Tone.mute,
};

Tone matchTone(String label) => switch (label) {
  'strong' => Tone.ok,
  'possible' => Tone.warn,
  _ => Tone.mute,
};

String matchStrength(String label) => switch (label) {
  'strong' => 'Strong',
  'possible' => 'Possible',
  _ => 'Weak',
};

/// Score pill such as "Strong · 0.91".
class ScorePill extends StatelessWidget {
  const ScorePill({super.key, required this.match, this.withLabel = true});
  final ItemMatch match;
  final bool withLabel;
  @override
  Widget build(BuildContext context) => StatusPill(
    withLabel
        ? '${matchStrength(match.label)} · ${match.score.toStringAsFixed(2)}'
        : match.score.toStringAsFixed(2),
    tone: matchTone(match.label),
  );
}
