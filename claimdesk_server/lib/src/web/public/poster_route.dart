import 'package:barcode/barcode.dart';
import 'package:serverpod/serverpod.dart';
import '../../cache_busting.dart';
import '../../services/signed_links.dart';
import 'public_page.dart';
import 'public_strings.dart';
import 'venue_page_route.dart';

/// A printable poster for any venue: a QR code to its venue page, the desk
/// hours as the venue entered them, and the same words in English and
/// Spanish, because one sheet on a wall serves every reader.
class PosterRoute extends PublicRoute {
  PosterRoute() : super(methods: {Method.get});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final venue = await publicVenue(session, request);
    if (venue == null) return PublicPage.notFound();
    final url = SignedLinks.webUrl(session, '/v/${venue.slug}');
    final values = <String, dynamic>{
      'name': venue.name,
      'deskHours': venue.deskHours,
      // Printed in two unbreakable parts, so a long address wraps only before
      // its path and never at a hyphen someone might type.
      'urlHost': '${url.host}${url.hasPort ? ':${url.port}' : ''}',
      'urlPath': url.path,
      'en': PublicStrings.en,
      'es': PublicStrings.es,
      'css': await cacheBustingConfig.assetPath('/web/css/poster.css'),
      'favicon': await cacheBustingConfig.assetPath('/web/images/favicon.svg'),
      'qr': Barcode.qrCode(
        errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
      ).toSvg(url.toString(), width: 400, height: 400, drawText: false),
    };
    return Response(
      200,
      body: Body.fromString(
        TemplateWidget(name: 'public/poster', values: values).render(),
        mimeType: MimeType.html,
      ),
      headers: PublicPage.headers(),
    );
  }
}
