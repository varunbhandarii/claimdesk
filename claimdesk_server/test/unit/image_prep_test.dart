import 'dart:typed_data';
import 'package:claimdesk_server/src/ai/image_prep.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  for (final orientation in [1, 6]) {
    test('orientation $orientation is baked into pixels and EXIF removed', () {
      final source = img.Image(width: 1500, height: 1000);
      source.exif.imageIfd.orientation = orientation;
      source.exif.imageIfd.make = 'Private camera';
      final result = prepareImage(img.encodeJpg(source))!;
      expect((
        result.width,
        result.height,
      ), orientation == 1 ? (1024, 683) : (683, 1024));
      final output = img.decodeJpg(result.jpeg)!;
      final thumb = img.decodeJpg(result.thumb)!;
      expect(output.exif.imageIfd.isEmpty, isTrue);
      expect(output.exif.gpsIfd.isEmpty, isTrue);
      expect(thumb.exif.imageIfd.isEmpty, isTrue);
      expect([thumb.width, thumb.height], contains(320));
    });
  }
  test('tiny images are not enlarged and invalid bytes are refused', () {
    final result = prepareImage(
      img.encodePng(img.Image(width: 300, height: 200)),
    )!;
    expect((result.width, result.height), (300, 200));
    expect(img.decodeJpg(result.thumb)!.width, 300);
    expect(prepareImage(Uint8List.fromList([1, 2, 3, 4])), isNull);
    expect(prepareImage(Uint8List(15 * 1024 * 1024 + 1)), isNull);
  });
  test('large pixel dimensions are refused before decoding', () {
    // A PNG header is enough for the decoder to reject or report the dimensions.
    final data = img.encodePng(img.Image(width: 1, height: 1));
    ByteData.sublistView(data).setUint32(16, 100000);
    ByteData.sublistView(data).setUint32(20, 100000);
    expect(prepareImage(data), isNull);
  });
}
