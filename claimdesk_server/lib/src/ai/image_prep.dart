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
    final orientation = decoded.exif.imageIfd.orientation;
    final oriented = orientation == null || orientation == 1
        ? decoded
        : img.bakeOrientation(decoded);
    img.Image pixelsAt(img.Image source, int limit) {
      final longEdge = max(source.width, source.height);
      final resized = longEdge <= limit
          ? source
          : img.copyResize(
              source,
              width: max(1, (source.width * limit / longEdge).round()),
              height: max(1, (source.height * limit / longEdge).round()),
              interpolation: img.Interpolation.average,
            );
      // Copy only pixel bytes, never metadata. Opaque RGB needs no alpha blend.
      if (resized.format == img.Format.uint8 &&
          resized.numChannels == 3 &&
          !resized.hasPalette) {
        final pixels = resized.getBytes();
        return img.Image.fromBytes(
          width: resized.width,
          height: resized.height,
          bytes: pixels.buffer,
          bytesOffset: pixels.offsetInBytes,
          numChannels: 3,
        );
      }
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

    final normal = pixelsAt(oriented, 1024);
    final thumb = pixelsAt(normal, 320);
    final encoder = img.JpegEncoder(quality: 85);
    final jpeg = encoder.encode(normal, chroma: img.JpegChroma.yuv420);
    encoder.setQuality(80);
    return PreparedImage(
      jpeg,
      encoder.encode(thumb, chroma: img.JpegChroma.yuv420),
      normal.width,
      normal.height,
    );
  } catch (_) {
    return null;
  }
}
