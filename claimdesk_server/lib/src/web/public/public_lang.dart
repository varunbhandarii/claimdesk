import 'package:serverpod/serverpod.dart';

/// The languages the public pages are written in.
enum PublicLang {
  en,
  es;

  /// `en` or `es`, ignoring case and spaces; anything else is null.
  static PublicLang? parse(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'en' => PublicLang.en,
        'es' => PublicLang.es,
        _ => null,
      };

  /// The preferred of English and Spanish in an `Accept-Language` header:
  /// the highest weight wins, then the earlier tag. Regional tags such as
  /// `es-US` and `es-419` count as Spanish; other languages are ignored.
  static PublicLang? fromAcceptLanguage(String? header) {
    if (header == null) return null;
    PublicLang? best;
    var bestWeight = 0.0;
    for (final part in header.split(',')) {
      final pieces = part.split(';');
      final lang = parse(pieces.first.trim().split('-').first);
      if (lang == null) continue;
      var weight = 1.0;
      for (final param in pieces.skip(1)) {
        final pair = param.trim().split('=');
        if (pair.length == 2 && pair.first.trim() == 'q') {
          weight = double.tryParse(pair.last.trim()) ?? 0;
        }
      }
      if (weight > bestWeight) {
        best = lang;
        bestWeight = weight;
      }
    }
    return best;
  }
}

/// The language of one public request, and whether the visitor picked it.
///
/// A `lang` query parameter wins, then the hidden `lang` field a form
/// carries, then the browser's `Accept-Language`, then English. Nothing is
/// stored: links and redirects carry the choice instead of a cookie.
class PublicLocale {
  const PublicLocale(
    this.lang, {
    this.chosen = false,
    this.switchable = false,
    this.page,
  });

  static const english = PublicLocale(PublicLang.en);

  factory PublicLocale.of(Request request, {Map<String, String>? form}) {
    final picked =
        PublicLang.parse(request.url.queryParameters['lang']) ??
        PublicLang.parse(form?['lang']);
    return PublicLocale(
      picked ??
          PublicLang.fromAcceptLanguage(
            request.headers['accept-language']?.join(','),
          ) ??
          PublicLang.en,
      chosen: picked != null,
      switchable: true,
    );
  }

  final PublicLang lang;

  /// Whether the visitor picked the language with a link or a form field.
  final bool chosen;

  /// Whether the page shows a link to the other language.
  final bool switchable;

  /// Where the switch leads when it is not the current address, as on pages
  /// rendered in answer to a form post; null keeps the current path.
  final String? page;

  /// The same language, with the switch pointing at [page].
  PublicLocale at(String page) =>
      PublicLocale(lang, chosen: chosen, switchable: true, page: page);

  String get code => lang.name;
  bool get spanish => lang == PublicLang.es;

  /// Whether links and forms carry the language: always for Spanish, and for
  /// English when the visitor picked it over a Spanish browser.
  bool get carried => chosen || spanish;

  /// [target] with `lang=` added when the language travels with links.
  String link(String target) =>
      carried ? '$target${target.contains('?') ? '&' : '?'}lang=$code' : target;

  /// The same page in the other language. Relative by default, so a ticket
  /// page never repeats its private address in its own markup.
  String? get switchHref => switchable
      ? '${page ?? ''}?lang=${spanish ? PublicLang.en.name : PublicLang.es.name}'
      : null;
}
