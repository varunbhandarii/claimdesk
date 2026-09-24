import '../generated/protocol.dart';
import '../policy/taxonomy.dart';

bool restrictedAttributes(ItemAttributes a) =>
    a.containsPersonalData || Taxonomy.isRestricted(a.category);

ItemAttributes protectAttributes(ItemAttributes a) {
  if (!restrictedAttributes(a)) return a;
  return a.copyWith(
    description: Taxonomy.label(a.category),
    marks: [],
    brand: null,
    material: null,
    keywords: [],
    language: null,
  );
}

class TextTemplate {
  static String render(ItemAttributes attributes) {
    final a = protectAttributes(attributes);
    final synonyms = Taxonomy.synonyms[a.category] ?? [];
    final lines = [
      'Item: ${a.category}${synonyms.isEmpty ? '' : ' (${synonyms.join(', ')})'}',
    ];
    if (restrictedAttributes(a)) return lines.single;
    bool known(String? value) =>
        value != null &&
        value.trim().isNotEmpty &&
        value.toLowerCase() != 'unknown';
    if (a.colours.isNotEmpty) lines.add('Colours: ${a.colours.join(', ')}');
    if (known(a.brand)) lines.add('Brand: ${a.brand}');
    if (known(a.material)) lines.add('Material: ${a.material}');
    if (a.marks.isNotEmpty) {
      lines.add('Distinguishing marks: ${a.marks.join('; ')}');
    }
    if (known(a.description)) lines.add('Description: ${a.description}');
    return lines.join('\n');
  }
}
