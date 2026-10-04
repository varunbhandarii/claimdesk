import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../services/public_codes.dart';
import '../../services/public_intake_service.dart';
import '../middleware/rate_limit.dart';
import 'public_lang.dart';
import 'public_page.dart';
import 'public_strings.dart';
import 'public_views.dart';
import 'report_form_input.dart';
import 'venue_page_route.dart';

class LostFormRoute extends PublicRoute {
  LostFormRoute({required this.salt, required this.trustProxy})
    : super(methods: {Method.get, Method.post});
  final String salt;
  final bool trustProxy;
  @override
  Future<Result> handleCall(Session session, Request request) async {
    var locale = PublicLocale.of(request);
    final venue = await publicVenue(session, request);
    if (venue == null) return PublicPage.notFound(locale: locale);
    final zones = await Zone.db.find(
      session,
      where: (t) => t.venueId.equals(venue.id!),
      orderBy: (t) => t.sortOrder,
    );
    if (request.method == Method.get) {
      return PublicPage.html(
        'lost_form',
        FormView.of(venue, zones, lang: locale.lang),
        noStore: true,
        locale: locale,
      );
    }
    final contentType = request.headers['content-type']?.firstOrNull ?? '';
    if (!contentType.toLowerCase().startsWith(
      'application/x-www-form-urlencoded',
    )) {
      return PublicPage.unavailable(415, locale: locale);
    }
    final bytes = <int>[];
    var oversized = false;
    await for (final chunk in request.read()) {
      if (!oversized && bytes.length + chunk.length <= 16384) {
        bytes.addAll(chunk);
      } else {
        oversized = true;
        bytes.clear();
      }
    }
    if (oversized) return PublicPage.unavailable(413, locale: locale);
    Map<String, String> form;
    try {
      form = Uri.splitQueryString(utf8.decode(bytes));
    } on FormatException {
      return PublicPage.html(
        'lost_form',
        FormView.of(
          venue,
          zones,
          errors: {'rawText': PublicStrings.of(locale.lang)['errUnreadable']!},
          lang: locale.lang,
        ),
        status: 422,
        noStore: true,
        locale: locale,
      );
    }
    locale = PublicLocale.of(request, form: form);
    if ((form['website'] ?? '').trim().isNotEmpty) {
      return PublicPage.redirect(locale.link('/t/${PublicCodes().token()}'));
    }
    final parsed = ReportFormInput.parse(
      form,
      zones: zones.map((z) => z.id.toString()),
      now: DateTime.now(),
      timezone: venue.timezone,
      lang: locale.lang,
    );
    if (parsed.input == null) {
      return PublicPage.html(
        'lost_form',
        FormView.of(
          venue,
          zones,
          fields: form,
          errors: parsed.errors,
          lang: locale.lang,
        ),
        status: 422,
        noStore: true,
        locale: locale,
      );
    }
    stdout.writeln(
      'Public intake address source: ${clientAddressSource(request, trustProxy: trustProxy)}',
    );
    final result = await PublicIntakeService().submit(
      session,
      venue,
      parsed.input!,
      PublicCodes.ipHash(salt, clientAddress(request, trustProxy: trustProxy)),
    );
    return PublicPage.redirect(
      locale.link(
        '/t/${result.report.publicToken}${result.duplicate ? '?existing=1' : ''}',
      ),
    );
  }
}
