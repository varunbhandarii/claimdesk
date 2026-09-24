import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PreparedImage {
  PreparedImage(this.jpeg, this.thumb, this.width, this.height);
  final Uint8List jpeg, thumb;
  final int width, height;
}

PreparedImage? prepareImage(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 15 * 1024 * 1024) return null;
  try {
    final decoder = img.findDecoderForData(bytes);
    if (decoder is! img.JpegDecoder &&
        decoder is! img.PngDecoder &&
        decoder is! img.WebPDecoder) {
      return null;
    }
    final info = decoder!.startDecode(bytes);
    if (info == null ||
        info.width <= 0 ||
        info.height <= 0 ||
        info.width * info.height > 40000000 ||
        info.numFrames != 1) {
      return null;
    }
    final decoded = decoder.decodeFrame(0);
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    img.Image pixelsAt(int limit) {
      final longEdge = max(oriented.width, oriented.height);
      final resized = longEdge <= limit
          ? oriented
          : img.copyResize(
              oriented,
              width: max(1, (oriented.width * limit / longEdge).round()),
              height: max(1, (oriented.height * limit / longEdge).round()),
              interpolation: img.Interpolation.average,
            );
      final clean = img.Image(
        width: resized.width,
        height: resized.height,
        numChannels: 3,
      );
      img.fill(clean, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(clean, resized);
      clean.exif = img.ExifData();
      return clean;
    }

    final normal = pixelsAt(1024);
    final thumb = pixelsAt(320);
    return PreparedImage(
      img.encodeJpg(normal, quality: 85),
      img.encodeJpg(thumb, quality: 80),
      normal.width,
      normal.height,
    );
  } catch (_) {
    return null;
  }
}
