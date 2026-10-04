import 'package:serverpod/serverpod.dart';
import '../../cache_busting.dart';

class PublicPage {
  static Headers headers({bool noStore = false}) => Headers.build((h) {
    h['Cache-Control'] = [noStore ? 'no-store' : 'no-cache, private'];
    h['X-Robots-Tag'] = ['noindex'];
    h['X-Content-Type-Options'] = ['nosniff'];
    h['Referrer-Policy'] = ['no-referrer'];
    h['Content-Security-Policy'] = [
      "default-src 'self'; script-src 'none'; style-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'self'; frame-ancestors 'none'",
    ];
  });
  static Future<Response> html(
    String name,
    Map<String, dynamic> values, {
    int status = 200,
    bool noStore = false,
  }) async {
    final css = await cacheBustingConfig.assetPath('/web/css/public.css');
    final favicon = await cacheBustingConfig.assetPath(
      '/web/images/favicon.svg',
    );
    final view = {
      'title': values['name'] ?? 'ClaimDesk',
      ...values,
      'css': css,
      'favicon': favicon,
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
      headers: headers(noStore: noStore),
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
  static Future<Response> notFound() =>
      html('not_found', {}, status: 404, noStore: true);
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
      return PublicPage.html('unavailable', {}, status: 503, noStore: true);
    } finally {
      await session.close();
    }
  }
}
