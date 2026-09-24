import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import 'prompts/caption_v1.dart';
import 'text_template.dart';

class CaptionValidator {
  static ItemAttributes parse(
    Object? value, {
    required String modelId,
    required String promptVersion,
  }) {
    Never bad() => throw const FormatException('Invalid caption schema');
    if (value is! Map<String, dynamic>) bad();
    final root = value;
    final rootKeys = {
      'items',
      'primary_item_index',
      'contains_personal_data',
      'personal_data_kinds',
      'image_quality',
    };
    if (root.keys.toSet().difference(rootKeys).isNotEmpty ||
        rootKeys.difference(root.keys.toSet()).isNotEmpty) {
      bad();
    }
    final items = root['items'];
    final index = root['primary_item_index'];
    final personal = root['contains_personal_data'];
    final kinds = root['personal_data_kinds'];
    if (items is! List ||
        items.isEmpty ||
        items.length > 20 ||
        index is! int ||
        index < 0 ||
        index >= items.length ||
        personal is! bool ||
        kinds is! List ||
        kinds.any((v) => !personalDataKinds.contains(v)) ||
        !imageQualities.contains(root['image_quality'])) {
      bad();
    }
    final parsed = <ItemAttributes>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) bad();
      final m = raw;
      const keys = {
        'category',
        'category_confidence',
        'colours',
        'brand',
        'material',
        'marks',
        'description',
        'confidence',
      };
      if (keys.difference(m.keys.toSet()).isNotEmpty ||
          m.keys.toSet().difference(keys).isNotEmpty) {
        bad();
      }
      final category = m['category'];
      final colours = m['colours'];
      final marks = m['marks'];
      final desc = m['description'];
      bool bounded(Object? n) => n is num && n.isFinite && n >= 0 && n <= 1;
      if (!Taxonomy.groups.containsKey(category) ||
          !bounded(m['category_confidence']) ||
          !bounded(m['confidence']) ||
          colours is! List ||
          colours.length > 3 ||
          (colours.isEmpty && personal != true) ||
          colours.any((c) => !Taxonomy.colours.contains(c)) ||
          marks is! List ||
          marks.length > 5 ||
          marks.any((v) => v is! String || v.length > 300) ||
          desc is! String ||
          desc.trim().isEmpty ||
          desc.length > 2000 ||
          desc.trim().split(RegExp(r'\s+')).length > 60 ||
          (m['brand'] != null && m['brand'] is! String) ||
          (m['material'] != null && m['material'] is! String)) {
        bad();
      }
      String clean(String text) => personal == true
          ? text.replaceAll(RegExp(r'\d+'), '').trim()
          : text.trim();
      parsed.add(
        protectAttributes(
          ItemAttributes(
            category: category as String,
            categoryConfidence: (m['category_confidence'] as num).toDouble(),
            colours: (colours).cast<String>(),
            brand: m['brand'] == null ? null : clean(m['brand']),
            material: m['material'] == null ? null : clean(m['material']),
            marks: (marks).cast<String>().map(clean).toList(),
            description: clean(desc),
            containsPersonalData: personal,
            personalDataKinds: (kinds).cast<String>(),
            imageQuality: root['image_quality'],
            keywords: [],
            source: 'vision',
            modelId: modelId,
            promptVersion: promptVersion,
          ),
        ),
      );
    }
    return parsed[index];
  }
}
