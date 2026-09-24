import 'dart:typed_data';
import 'package:claimdesk_server/src/ai/image_prep.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  test(
    'downscaling averages high-frequency RGB details without colour aliasing',
    () {
      final source = img.Image(width: 2048, height: 16, numChannels: 3);
      for (var y = 0; y < source.height; y++) {
        for (var x = 0; x < source.width; x++) {
          source.setPixelRgb(x, y, x.isEven ? 255 : 0, 64, x.isEven ? 0 : 255);
        }
      }
      final result = prepareImage(img.encodePng(source))!;
      final pixel = img.decodeJpg(result.jpeg)!.getPixel(512, 4);
      expect(result.width, 1024);
      expect(pixel.r, closeTo(127, 5));
      expect(pixel.g, closeTo(64, 5));
      expect(pixel.b, closeTo(127, 5));
    },
  );
  test(
    'transparent PNG pixels are composited onto white before JPEG encoding',
    () {
      final source = img.Image(width: 20, height: 20, numChannels: 4);
      img.fill(source, color: img.ColorRgba8(255, 0, 0, 0));
      final output = prepareImage(Uint8List.fromList(img.encodePng(source)))!;
      final pixel = img.decodeJpg(output.jpeg)!.getPixel(10, 10);
      expect(pixel.r, greaterThanOrEqualTo(250));
      expect(pixel.g, greaterThanOrEqualTo(250));
      expect(pixel.b, greaterThanOrEqualTo(250));
    },
  );
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
