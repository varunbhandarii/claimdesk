import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';

String valueBandLabel(ValueBand band) => switch (band) {
  ValueBand.under20 => 'Under \$20',
  ValueBand.from20to99 => '\$20–99',
  ValueBand.from100to499 => '\$100–499',
  ValueBand.from500to4999 => '\$500–4,999',
  ValueBand.over5000 => '\$5,000 or more',
};

String _valueBandShort(ValueBand band) => switch (band) {
  ValueBand.over5000 => '\$5,000+',
  _ => valueBandLabel(band),
};

String? optionalText(String text) => text.trim().isEmpty ? null : text.trim();

class ItemFormController {
  ItemFormController({FoundItem? item, UuidValue? rememberedZone}) {
    final attrs = item?.attributes;
    category = attrs?.category ?? 'other';
    colours.addAll(attrs?.colours ?? []);
    zoneId = item?.zoneId ?? rememberedZone;
    valueBand = item?.valueBand ?? ValueBand.under20;
    brand.text = attrs?.brand ?? '';
    material.text = attrs?.material ?? '';
    description.text = attrs?.description ?? '';
    marks.text = attrs?.marks.join('\n') ?? '';
    bin.text = item?.storageBin ?? '';
    notes.text = item?.privateNotes ?? '';
    finder.text = item?.finderName ?? '';
  }
  late String category;
  late ValueBand valueBand;
  UuidValue? zoneId;
  final colours = <String>{};
  final brand = TextEditingController();
  final material = TextEditingController();
  final description = TextEditingController();
  final marks = TextEditingController();
  final bin = TextEditingController();
  final notes = TextEditingController();
  final finder = TextEditingController();
  void _validate({bool edit = false}) {
    if (colours.length > 3) {
      throw Exception('Choose up to three colours.');
    }
    final hint = description.text.trim();
    if (edit && hint.isEmpty) {
      throw Exception('Add a description before saving.');
    }
    if (hint.isNotEmpty && hint.split(RegExp(r'\s+')).length > 60) {
      throw Exception('Keep the description to 60 words or fewer.');
    }
    if (edit) {
      final lines = marks.text
          .split('\n')
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty);
      if (lines.length > 5 || lines.any((m) => m.length > 300)) {
        throw Exception(
          'Use up to five marks, each no longer than 300 characters.',
        );
      }
    }
  }

  CreateItemInput buildInput({PhotoUploadTicket? ticket}) {
    _validate();
    return CreateItemInput(
      itemId: ticket?.itemId,
      photoPath: ticket?.path,
      uploadProof: ticket?.proof,
      uploadExpiresAt: ticket?.expiresAt,
      zoneId: zoneId,
      category: category,
      colours: colours.toList(),
      brand: optionalText(brand.text),
      description: optionalText(description.text),
      valueBand: valueBand,
      storageBin: optionalText(bin.text),
      privateNotes: optionalText(notes.text),
      finderName: optionalText(finder.text),
    );
  }

  ItemPatch buildPatch(FoundItem item) {
    _validate(edit: true);
    return ItemPatch(
      attributes: ItemAttributes(
        category: category,
        colours: colours.toList(),
        brand: optionalText(brand.text),
        material: optionalText(material.text),
        marks: marks.text
            .split('\n')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty)
            .toList(),
        description: description.text.trim(),
        containsPersonalData: item.attributes?.containsPersonalData ?? false,
        personalDataKinds: item.attributes?.personalDataKinds ?? [],
        keywords: [],
        source: 'staff_typed',
      ),
      valueBand: valueBand,
      zoneId: zoneId,
      clearZone: zoneId == null,
      storageBin: optionalText(bin.text),
      clearStorageBin: optionalText(bin.text) == null,
      privateNotes: optionalText(notes.text),
      clearPrivateNotes: optionalText(notes.text) == null,
    );
  }

  void dispose() {
    for (final c in [brand, material, description, marks, bin, notes, finder]) {
      c.dispose();
    }
  }
}

class ItemForm extends StatefulWidget {
  const ItemForm({
    super.key,
    required this.controller,
    required this.zones,
    required this.onChanged,
    this.edit = false,
    this.enabled = true,
    this.handoffHint,
  });
  final ItemFormController controller;
  final List<Zone> zones;
  final VoidCallback onChanged;
  final bool edit;
  final bool enabled;

  /// Explains which value bands start the police hand-off timer.
  final String? handoffHint;
  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  bool _more = true;

  void _change(VoidCallback action) {
    setState(action);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final d = context.desk;
    Widget field(
      String label,
      TextEditingController controller,
      int limit, {
      int lines = 1,
      String? hint,
      String? placeholder,
    }) => LabeledField(
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        enabled: widget.enabled,
        maxLength: limit,
        maxLines: lines,
        minLines: 1,
        decoration: InputDecoration(hintText: placeholder, counterText: ''),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: 'Zone',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DeskLabel(
                      widget.edit
                          ? 'Where was it found?'
                          : 'Where was it found? · Required',
                    ),
                  ),
                  if (widget.edit && c.zoneId != null)
                    TextButton(
                      onPressed: widget.enabled
                          ? () => _change(() => c.zoneId = null)
                          : null,
                      child: const Text('Clear zone'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.zones.isEmpty)
                Text(
                  'No zones loaded yet.',
                  style: TextStyle(color: d.ink3),
                )
              else
                LayoutBuilder(
                  builder: (context, box) {
                    final columns = box.maxWidth >= 520 ? 3 : 2;
                    final width = ((box.maxWidth - 8 * (columns - 1)) / columns)
                        .floorToDouble();
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final zone in widget.zones)
                          SizedBox(
                            width: width,
                            child: _ZoneButton(
                              label: zone.name,
                              selected: c.zoneId == zone.id,
                              onPressed: widget.enabled
                                  ? () => _change(() => c.zoneId = zone.id)
                                  : null,
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DeskLabel(widget.edit ? 'Category' : 'Category · optional'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: c.category,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: [
            for (final entry in categories.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.key == 'other' ? 'Other or not sure' : entry.value,
                ),
              ),
            if (!categories.containsKey(c.category))
              DropdownMenuItem(
                value: c.category,
                child: Text(
                  '${categoryLabel(c.category)} · ${fineLabel(c.category)}',
                ),
              ),
          ],
          onChanged: widget.enabled
              ? (value) => _change(() => c.category = value!)
              : null,
        ),
        const SizedBox(height: 24),
        const DeskLabel('Colours · up to three'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, box) {
            final columns = (box.maxWidth / 64).floor().clamp(4, 9);
            final width = (box.maxWidth / columns).floorToDouble();
            return Wrap(
              runSpacing: 14,
              children: [
                for (final colour in colours)
                  SizedBox(
                    width: width,
                    child: ColourSwatchButton(
                      colour: colour,
                      selected: c.colours.contains(colour),
                      onPressed:
                          widget.enabled &&
                              (c.colours.contains(colour) ||
                                  c.colours.length < 3)
                          ? () => _change(() {
                              if (!c.colours.remove(colour)) {
                                c.colours.add(colour);
                              }
                            })
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        DeskCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _more = !_more),
                child: Semantics(
                  button: true,
                  expanded: _more,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'More details',
                            style: context.type.strong.copyWith(fontSize: 16),
                          ),
                        ),
                        Icon(
                          _more ? Icons.expand_less : Icons.expand_more,
                          color: d.ink,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_more)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Value',
                        style: context.type.strong.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _ValueBands(
                        value: c.valueBand,
                        onChanged: widget.enabled
                            ? (band) => _change(() => c.valueBand = band)
                            : null,
                      ),
                      if (widget.handoffHint != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.handoffHint!,
                          style: context.type.small.copyWith(color: d.ink3),
                        ),
                      ],
                      const SizedBox(height: 18),
                      field(
                        'Description',
                        c.description,
                        500,
                        lines: 3,
                        hint: widget.edit
                            ? 'Required. Up to 60 words.'
                            : 'Used if the photo cannot be described.',
                        placeholder: 'What would someone notice first?',
                      ),
                      const SizedBox(height: 16),
                      field('Brand', c.brand, 100, placeholder: 'If visible'),
                      if (widget.edit) ...[
                        const SizedBox(height: 16),
                        field('Material', c.material, 100),
                        const SizedBox(height: 16),
                        field(
                          'Marks',
                          c.marks,
                          1000,
                          lines: 3,
                          hint: 'One per line, up to five.',
                        ),
                      ],
                      const SizedBox(height: 16),
                      field(
                        'Storage bin',
                        c.bin,
                        100,
                        placeholder: 'e.g. Shelf B2',
                      ),
                      const SizedBox(height: 16),
                      field(
                        'Private notes',
                        c.notes,
                        4000,
                        lines: 3,
                        hint: 'Staff only. Never shown to the public.',
                        placeholder: 'Where it was, who handed it in',
                      ),
                      if (!widget.edit) ...[
                        const SizedBox(height: 16),
                        field(
                          'Finder name',
                          c.finder,
                          200,
                          hint: 'Staff only.',
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneButton extends StatelessWidget {
  const _ZoneButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 46),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: selected ? c.ink : c.surface,
          foregroundColor: selected ? c.inkOn : c.ink2,
          side: BorderSide(color: selected ? c.ink : c.line, width: 1.5),
          textStyle: context.type.strong.copyWith(fontSize: 13.5),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Round colour swatch with its name underneath.
class ColourSwatchButton extends StatelessWidget {
  const ColourSwatchButton({
    super.key,
    required this.colour,
    required this.selected,
    required this.onPressed,
  });
  final String colour;
  final bool selected;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final label = colour == 'multicolour' ? 'Multi' : colourLabel(colour);
    return Semantics(
      button: true,
      selected: selected,
      enabled: onPressed != null,
      label: colourLabel(colour),
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null && !selected ? .38 : 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? c.ink : const Color(0x00000000),
                      width: 2.5,
                    ),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: colourDecoration(colour),
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: _checkColour(colour),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: (selected ? context.type.strong : context.type.body)
                      .copyWith(
                        fontSize: 11.5,
                        color: selected ? c.ink : c.ink2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _checkColour(String colour) => switch (colour) {
    'white' ||
    'silver' ||
    'gold' ||
    'yellow' ||
    'pink' ||
    'beige' ||
    'transparent' ||
    'orange' => const Color(0xFF16181B),
    _ => const Color(0xFFFFFFFF),
  };
}

class _ValueBands extends StatelessWidget {
  const _ValueBands({required this.value, required this.onChanged});
  final ValueBand value;
  final ValueChanged<ValueBand>? onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.line, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final band in ValueBand.values) ...[
                if (band.index > 0) Container(width: 1, color: c.line),
                Expanded(
                  child: Semantics(
                    selected: band == value,
                    inMutuallyExclusiveGroup: true,
                    button: true,
                    label: valueBandLabel(band),
                    excludeSemantics: true,
                    child: Material(
                      color: band == value ? c.ink : c.surface,
                      child: InkWell(
                        onTap: onChanged == null
                            ? null
                            : () => onChanged!(band),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            _valueBandShort(band),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: context.type.strong.copyWith(
                              fontSize: 12.5,
                              height: 1.15,
                              color: band == value ? c.inkOn : c.ink2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
