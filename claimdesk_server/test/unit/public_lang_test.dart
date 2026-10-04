import 'package:claimdesk_server/src/web/public/public_lang.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

Request request(String path, {String? acceptLanguage}) =>
    RequestInternal.create(
      Method.get,
      Uri.parse('http://localhost$path'),
      Object(),
      headers: Headers.build((h) {
        if (acceptLanguage != null) h['Accept-Language'] = [acceptLanguage];
      }),
    );

void main() {
  test('language codes parse loosely and nothing else counts', () {
    expect(PublicLang.parse('es'), PublicLang.es);
    expect(PublicLang.parse(' EN '), PublicLang.en);
    for (final value in [null, '', 'fr', 'es-US', 'spanish']) {
      expect(PublicLang.parse(value), isNull, reason: '$value');
    }
  });

  test('Accept-Language picks the heavier of English and Spanish', () {
    expect(
      PublicLang.fromAcceptLanguage('es-US,es;q=0.9,en;q=0.8'),
      PublicLang.es,
    );
    expect(PublicLang.fromAcceptLanguage('es-419'), PublicLang.es);
    expect(
      PublicLang.fromAcceptLanguage('en-US,en;q=0.9,es;q=0.8'),
      PublicLang.en,
    );
    expect(
      PublicLang.fromAcceptLanguage('fr-FR,fr;q=0.9,es;q=0.5,en;q=0.4'),
      PublicLang.es,
    );
    expect(PublicLang.fromAcceptLanguage('en;q=0.5, es;q=0.5'), PublicLang.en);
    expect(PublicLang.fromAcceptLanguage('es;q=0, en;q=0.1'), PublicLang.en);
    expect(PublicLang.fromAcceptLanguage('de, fr'), isNull);
    expect(PublicLang.fromAcceptLanguage('*'), isNull);
    expect(PublicLang.fromAcceptLanguage(null), isNull);
  });

  test('the query beats the form field, which beats the browser', () {
    final browserSpanish = request('/v/desk', acceptLanguage: 'es-US,es');
    final fromBrowser = PublicLocale.of(browserSpanish);
    expect(fromBrowser.lang, PublicLang.es);
    expect(fromBrowser.chosen, isFalse);
    expect(fromBrowser.switchable, isTrue);

    final queried = PublicLocale.of(
      request('/v/desk?lang=en', acceptLanguage: 'es'),
      form: {'lang': 'es'},
    );
    expect(queried.lang, PublicLang.en);
    expect(queried.chosen, isTrue);

    final posted = PublicLocale.of(
      request('/v/desk/lost', acceptLanguage: 'en'),
      form: {'lang': 'es'},
    );
    expect(posted.lang, PublicLang.es);
    expect(posted.chosen, isTrue);

    final unknown = PublicLocale.of(
      request('/v/desk?lang=fr', acceptLanguage: 'de'),
      form: {'lang': 'xx'},
    );
    expect(unknown.lang, PublicLang.en);
    expect(unknown.chosen, isFalse);
  });

  test('links carry Spanish, and English only when picked', () {
    final plain = PublicLocale.of(request('/t/token'));
    expect(plain.carried, isFalse);
    expect(plain.link('/v/desk/lost'), '/v/desk/lost');
    expect(plain.switchHref, '?lang=es');

    final spanish = PublicLocale.of(request('/t/token', acceptLanguage: 'es'));
    expect(spanish.link('/t/token'), '/t/token?lang=es');
    expect(spanish.link('?edit=1'), '?edit=1&lang=es');
    expect(spanish.switchHref, '?lang=en');

    final pickedEnglish = PublicLocale.of(
      request('/t/token?lang=en', acceptLanguage: 'es'),
    );
    expect(pickedEnglish.link('/v/desk'), '/v/desk?lang=en');

    expect(
      spanish.at('/t/other').switchHref,
      '/t/other?lang=en',
    );
    expect(PublicLocale.english.switchHref, isNull);
  });
}
