import 'dart:io';
import 'package:barcode/barcode.dart';

void main() {
  const url = 'https://claimdesk-vb.serverpod.space/v/hawrys-demo';
  final svg = Barcode.qrCode(
    errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
  ).toSvg(url, width: 400, height: 400, drawText: false);
  File('web/static/images/qr-hawrys-demo.svg').writeAsStringSync(svg);
  stdout.writeln('Venue QR poster asset generated.');
}
