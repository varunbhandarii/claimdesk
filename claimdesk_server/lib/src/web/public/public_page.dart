import 'package:serverpod/serverpod.dart';
import '../../cache_busting.dart';
import 'public_lang.dart';
import 'public_strings.dart';

class PublicPage {
  static Headers headers({
    bool noStore = false,
    PublicLocale? locale,
  }) => Headers.build((h) {
    h['Cache-Control'] = [noStore ? 'no-store' : 'no-cache, private'];
    h['X-Robots-Tag'] = ['noindex'];
    h['X-Content-Type-Options'] = ['nosniff'];
    h['Referrer-Policy'] = ['no-referrer'];
    h['Content-Security-Policy'] = [
      "default-src 'self'; script-src 'none'; style-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'self'; frame-ancestors 'none'",
    ];
    if (locale != null) {
      h['Content-Language'] = [locale.code];
      h['Vary'] = ['Accept-Language'];
    }
  });

  /// Renders a public page in the locale's language. Templates read text as
  /// `{{t.key}}`; links that keep the language are `formHref`, `venueHref`
  /// and `langField` for forms.
  static Future<Response> html(
    String name,
    Map<String, dynamic> values, {
    int status = 200,
    bool noStore = false,
    PublicLocale locale = PublicLocale.english,
  }) async {
    final css = await cacheBustingConfig.assetPath('/web/css/public.css');
    final favicon = await cacheBustingConfig.assetPath(
      '/web/images/favicon.svg',
    );
    final t = PublicStrings.of(locale.lang);
    final slug = values['slug'];
    final switchHref = locale.switchHref;
    final view = {
      'title': values['name'] ?? 'ClaimDesk',
      ...values,
      'css': css,
      'favicon': favicon,
      't': t,
      'lang': locale.code,
      'langField': locale.carried ? locale.code : null,
      'switch': switchHref == null
          ? null
          : {
              'href': switchHref,
              'label': t['switchLabel'],
              'lang': locale.spanish ? PublicLang.en.name : PublicLang.es.name,
            },
      if (slug is String) ...{
        'formHref': locale.link('/v/$slug/lost'),
        'venueHref': locale.link('/v/$slug'),
      },
    };
    final html = ListWidget(
      widgets: [
        TemplateWidget(name: 'public/header', values: view),
        TemplateWidget(name: 'public/$name', values: view),
        TemplateWidget(name: 'public/footer', values: view),
      ],
    ).render();
    return Response(
      status,
      body: Body.fromString(html, mimeType: MimeType.html),
      headers: headers(noStore: noStore, locale: locale),
    );
  }

  static Response json(Object values, {int status = 200}) => Response(
    status,
    body: Body.fromString(
      JsonWidget(object: values).render(),
      mimeType: MimeType.json,
    ),
    headers: headers(noStore: true),
  );
  static Response redirect(String path) =>
      Response.seeOther(Uri.parse(path), headers: headers(noStore: true));
  static Future<Response> notFound({
    PublicLocale locale = PublicLocale.english,
  }) => html('not_found', {}, status: 404, noStore: true, locale: locale);
  static Future<Response> unavailable(
    int status, {
    PublicLocale locale = PublicLocale.english,
  }) => html('unavailable', {}, status: status, noStore: true, locale: locale);
}

/// Public requests deliberately avoid sessions that log URLs or SQL values.
abstract class PublicRoute extends Route {
  PublicRoute({super.methods});
  @override
  Future<Result> call(Request req) async {
    final session = await Serverpod.instance.createSession(
      enableLogging: false,
    );
    try {
      return await handleCall(session, req);
    } catch (_) {
      return PublicPage.unavailable(503, locale: PublicLocale.of(req));
    } finally {
      await session.close();
    }
  }
}
