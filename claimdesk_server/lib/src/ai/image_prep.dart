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
      final width = max(1, (source.width * min(1, limit / longEdge)).round());
      final height = max(1, (source.height * min(1, limit / longEdge)).round());
      if (source.format == img.Format.uint8 &&
          source.numChannels == 3 &&
          !source.hasPalette) {
        return _resizeRgb(source, width, height);
      }
      final resized = longEdge <= limit
          ? source
          : img.copyResize(
              source,
              width: max(1, (source.width * limit / longEdge).round()),
              height: max(1, (source.height * limit / longEdge).round()),
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

// The common JPEG path averages byte channels directly, avoiding per-pixel
// polymorphic getters and floating-point conversions on small server CPUs.
// A fresh image owns the output pixels and never inherits source metadata.
img.Image _resizeRgb(img.Image source, int width, int height) {
  final pixels = source.getBytes();
  if (width == source.width && height == source.height) {
    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: pixels.buffer,
      bytesOffset: pixels.offsetInBytes,
      numChannels: 3,
    );
  }
  final clean = img.Image(width: width, height: height, numChannels: 3);
  final output = clean.data!.toUint8List();
  final xStarts = List<int>.generate(width, (x) => x * source.width ~/ width);
  final xEnds = List<int>.generate(
    width,
    (x) => (x + 1) * source.width ~/ width,
  );
  var target = 0;
  for (var y = 0; y < height; y++) {
    final yStart = y * source.height ~/ height,
        yEnd = (y + 1) * source.height ~/ height;
    for (var x = 0; x < width; x++) {
      final xStart = xStarts[x], xEnd = xEnds[x];
      var red = 0, green = 0, blue = 0;
      for (var sy = yStart; sy < yEnd; sy++) {
        var offset = (sy * source.width + xStart) * 3;
        final end = (sy * source.width + xEnd) * 3;
        while (offset < end) {
          red += pixels[offset++];
          green += pixels[offset++];
          blue += pixels[offset++];
        }
      }
      final count = (xEnd - xStart) * (yEnd - yStart);
      output[target++] = red ~/ count;
      output[target++] = green ~/ count;
      output[target++] = blue ~/ count;
    }
  }
  return clean;
}
