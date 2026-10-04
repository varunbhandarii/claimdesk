import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';

/// What the desk knows about an item from its photo or staff notes: the
/// description, colours, brand and material, and distinguishing marks.
class AttributeChips extends StatelessWidget {
  const AttributeChips({
    super.key,
    required this.attributes,
    this.restricted = false,
  });
  final ItemAttributes attributes;
  final bool restricted;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final fromPhoto = attributes.source != 'staff_typed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          'What the desk sees',
          trailing: TitleNote(fromPhoto ? 'From the photo' : 'Typed by staff'),
        ),
        if (attributes.description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(attributes.description.trim()),
        ],
        const SizedBox(height: 12),
        ColourNames(
          attributes.colours,
          extra: [
            if (attributes.brand != null) attributes.brand!,
            if (attributes.material != null) capitalise(attributes.material!),
          ],
        ),
        if (attributes.marks.isNotEmpty) const SizedBox(height: 12),
        for (final mark in attributes.marks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: BoxDecoration(
                    color: c.tag,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(child: Text(mark)),
              ],
            ),
          ),
        if (restricted) ...[
          const SizedBox(height: 12),
          NoteStrip(
            icon: Icons.lock_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Staff only — this item is never shown publicly.'),
                if (attributes.personalDataKinds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final kind in attributes.personalDataKinds)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            fineLabel(kind),
                            style: context.type.strong.copyWith(
                              fontSize: 12.5,
                              color: c.ink2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
