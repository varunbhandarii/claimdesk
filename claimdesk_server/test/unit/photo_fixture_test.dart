import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test(
    'photo fixture uses each seed key and exactly its captured vision attributes',
    () {
      final fixture =
          jsonDecode(
                File(
                  'test/fixtures/matching/synthetic_v1.json',
                ).readAsStringSync(),
              )
              as Map;
      final captured =
          jsonDecode(
                File(
                  'test/fixtures/matching/photo_captions_v1.json',
                ).readAsStringSync(),
              )['items']
              as Map;
      final seedKeys = (fixture['seedItems'] as List).toSet();
      final photos = fixture['photoItems'] as List;
      expect(photos.map((r) => r['key']).toSet(), seedKeys);
      expect(photos, hasLength(30));
      expect(fixture['items'], hasLength(40));
      expect(fixture['reports'], hasLength(30));
      for (final row in photos) {
        expect(row['attributes'], captured[row['key']]);
        expect(row['attributes']['source'], 'vision');
        expect(row['attributes']['modelId'], 'claude-opus-5-5');
        expect(row['attributes']['promptVersion'], 'caption_v1');
        expect(
          File('test/fixtures/photos/generated/${row['key']}.jpg').existsSync(),
          true,
        );
      }
      final reports = fixture['photoReports'] as List;
      expect(reports, hasLength(15));
      expect(reports.where((r) => r['expectedItem'] == null), hasLength(3));
      expect(
        reports
            .where((r) => r['expectedItem'] != null)
            .every((r) => seedKeys.contains(r['expectedItem'])),
        true,
      );
    },
  );
}
