import 'dart:convert';
import 'dart:io';

/// Bundle only the original text selected for the demo; tests stay out of Cloud.
void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/matching/synthetic_v1.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final result = <String, Object?>{'version': fixture['version']};
  for (final kind in ['items', 'reports']) {
    final selection =
        (fixture[kind == 'items' ? 'seedItems' : 'seedReports'] as List)
            .cast<String>();
    final byKey = {
      for (final row in fixture[kind] as List) row['key'] as String: row,
    };
    result[kind] = [for (final key in selection) byKey[key]!];
  }
  final file = File('lib/src/seed/demo_inventory.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(result)}\n',
  );
}
