import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';

String valueBandLabel(ValueBand band) => switch (band) {
  ValueBand.under20 => 'Under \$20',
  ValueBand.from20to99 => '\$20–99',
  ValueBand.from100to499 => '\$100–499',
  ValueBand.from500to4999 => '\$500–4,999',
  ValueBand.over5000 => '\$5,000 or more',
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
  });
  final ItemFormController controller;
  final List<Zone> zones;
  final VoidCallback onChanged;
  final bool edit;
  final bool enabled;
  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  void _change(VoidCallback action) {
    setState(action);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    Widget field(
      String label,
      TextEditingController controller,
      int limit, {
      int lines = 1,
    }) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: controller,
        enabled: widget.enabled,
        maxLength: limit,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<UuidValue>(
          key: ValueKey('zone_${c.zoneId}'),
          initialValue: c.zoneId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Zone *'),
          items: [
            for (final zone in widget.zones)
              DropdownMenuItem(value: zone.id, child: Text(zone.name)),
          ],
          onChanged: widget.enabled
              ? (id) => _change(() => c.zoneId = id)
              : null,
        ),
        if (widget.edit && c.zoneId != null)
          TextButton(
            onPressed: widget.enabled
                ? () => _change(() => c.zoneId = null)
                : null,
            child: const Text('Clear zone'),
          ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: c.category,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            for (final entry in categories.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
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
        const SizedBox(height: 20),
        const Text('Colours · choose up to three'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final colour in colours)
              FilterChip(
                label: Text(colour),
                selected: c.colours.contains(colour),
                onSelected:
                    widget.enabled &&
                        (c.colours.contains(colour) || c.colours.length < 3)
                    ? (selected) => _change(() {
                        if (selected) {
                          c.colours.add(colour);
                        } else {
                          c.colours.remove(colour);
                        }
                      })
                    : null,
              ),
          ],
        ),
        field('Brand', c.brand, 100),
        field('Description / identifying hint', c.description, 500, lines: 3),
        if (widget.edit) ...[
          field('Material', c.material, 100),
          field('Marks · one per line', c.marks, 1000, lines: 3),
        ],
        field('Storage bin', c.bin, 100),
        const SizedBox(height: 16),
        DropdownButtonFormField<ValueBand>(
          initialValue: c.valueBand,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Value band'),
          items: [
            for (final value in ValueBand.values)
              DropdownMenuItem(
                value: value,
                child: Text(valueBandLabel(value)),
              ),
          ],
          onChanged: widget.enabled
              ? (value) => _change(() => c.valueBand = value!)
              : null,
        ),
        field('Private notes · staff only', c.notes, 4000, lines: 3),
        if (!widget.edit) field('Finder name · staff only', c.finder, 200),
      ],
    );
  }
}
