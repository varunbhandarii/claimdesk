import 'package:barcode/barcode.dart';
import 'package:serverpod/serverpod.dart';
import '../../cache_busting.dart';
import '../../generated/protocol.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../policy/item_titles.dart';
import '../../policy/taxonomy.dart';
import '../../services/signed_links.dart';
import 'public_page.dart';
import 'public_views.dart';
import 'report_form_input.dart';

class TagRoute extends PublicRoute {
  TagRoute() : super(methods: {Method.get});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final raw = request.pathParameters.raw[#itemId];
    if (raw == null) return PublicPage.notFound();
    UuidValue id;
    try {
      id = UuidValue.fromString(raw);
    } on FormatException {
      return PublicPage.notFound();
    }
    if (!SignedLinks.verifyTag(
      session,
      id,
      request.queryParameters.raw['exp'],
      request.queryParameters.raw['sig'],
    )) {
      return PublicPage.notFound();
    }
    final item = await FoundItem.db.findById(session, id);
    if (item == null) return PublicPage.notFound();
    final venue = await Venue.db.findById(session, item.venueId);
    if (venue == null) return PublicPage.notFound();
    final zone = item.zoneId == null
        ? null
        : await Zone.db.findById(session, item.zoneId!);
    final location = ReportFormInput.location(venue.timezone);
    String date(DateTime at) {
      final local = tz.TZDateTime.from(at, location);
      return '${shortDay(local)}, ${local.year}';
    }

    final colours = item.attributes?.colours ?? const <String>[];
    final values = <String, dynamic>{
      'name': venue.name,
      'reference': item.refCode,
      'title': ItemTitles.title(item.attributes),
      'category': Taxonomy.label(item.attributes?.category ?? 'other'),
      'colours': colours.join(', '),
      'hasColours': colours.isNotEmpty,
      'found': date(item.foundAt),
      'logged': date(item.createdAt),
      'zone': zone?.venueId == item.venueId ? zone?.name : 'No zone',
      'bin': item.storageBin ?? 'Not assigned',
      'css': await cacheBustingConfig.assetPath('/web/css/tag.css'),
      'qr': Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium)
          .toSvg(
            SignedLinks.webUrl(
              session,
              '/app/',
              query: {'item': item.refCode},
            ).toString(),
            width: 200,
            height: 200,
            drawText: false,
          ),
    };
    return Response(
      200,
      body: Body.fromString(
        TemplateWidget(name: 'public/tag', values: values).render(),
        mimeType: MimeType.html,
      ),
      headers: PublicPage.headers(noStore: true),
    );
  }
}
