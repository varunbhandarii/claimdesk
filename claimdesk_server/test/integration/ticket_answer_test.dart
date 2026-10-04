@Tags(['integration'])
library;

import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/ticket_answer_route.dart';
import 'package:claimdesk_server/src/web/public/ticket_route.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Ticket answer transport', (builder, _) {
    test(
      'Validation, corrections, bot trap and state refusals preserve privacy headers',
      () async {
        final s = builder.build();
        final venue = await makeVenue(s);
        final item = await makeItem(s, venue.id!);
        var report = await makeReport(
          s,
          venue.id!,
          publicToken: 'abcdefghijklmnopqrstuv',
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(
            status: ReportStatus.possibleMatch,
            categoryHint: 'umbrella',
          ),
        );
        final match = await makeMatch(s, item, report);
        await ItemMatch.db.updateRow(
          s,
          match.copyWith(state: MatchState.confirmed),
        );
        await templates.loadAll(Directory('web/templates'));
        final router = RelicRouter();
        router.post(
          '/t/:token/answer',
          (req) => TicketAnswerRoute().handleCall(s, req),
        );
        router.get('/t/:token', (req) => TicketRoute().handleCall(s, req));
        Future<Response> call(
          Map<String, String>? fields, {
          String suffix = '',
        }) async =>
            await router(
                  RequestInternal.create(
                    fields == null ? Method.get : Method.post,
                    Uri.parse(
                      'http://localhost/t/${report.publicToken}${fields == null ? suffix : '/answer'}',
                    ),
                    Object(),
                    headers: Headers.build(
                      (h) => h['Content-Type'] = [
                        'application/x-www-form-urlencoded',
                      ],
                    ),
                    body: fields == null
                        ? Body.empty()
                        : Body.fromString(Uri(queryParameters: fields).query),
                  ),
                )
                as Response;
        final bad = await call({'answer1': '<script>', 'answer2': 'too short'});
        expect(bad.statusCode, 422);
        expect(await bad.readAsString(), contains('&lt;script&gt;'));
        expect(bad.headers['cache-control'], ['no-store']);
        expect(bad.headers['referrer-policy'], ['no-referrer']);
        expect((await call({'website': 'bot'})).statusCode, 303);
        expect(await ReportAnswer.db.count(s), 0);
        for (final value in [
          'A wooden handle with a chipped tip',
          'A replacement proof with a cloth loop',
        ]) {
          expect(
            (await call({
              'answer1': value,
              'answer2': 'Reception just after twelve',
            })).statusCode,
            303,
          );
        }
        expect(await ReportAnswer.db.count(s), 2);
        expect(
          await (await call(null)).readAsString(),
          contains('Answers received'),
        );
        expect(
          await (await call(null, suffix: '?edit=1')).readAsString(),
          contains('replacement proof'),
        );
        final spanish = await (await call(
          null,
          suffix: '?lang=es',
        )).readAsString();
        expect(spanish, contains('Respuestas recibidas.'));
        expect(spanish, contains('¿De qué material es el mango'));
        expect(spanish, contains('href="?edit=1&amp;lang=es"'));
        final spanishBad = await call({
          'lang': 'es',
          'answer1': 'corto',
          'answer2': 'Recepción poco después de las doce',
        });
        expect(spanishBad.statusCode, 422);
        final spanishBadHtml = await spanishBad.readAsString();
        expect(
          spanishBadHtml,
          contains('Use de 10 a 300 caracteres en esta respuesta.'),
        );
        expect(spanishBadHtml, contains('<html lang="es">'));
        expect(
          spanishBadHtml,
          contains('href="&#x2F;t&#x2F;${report.publicToken}?lang=en"'),
        );
        final spanishSent = await call({
          'lang': 'es',
          'answer1': 'Mango de madera con la punta astillada',
          'answer2': 'Recepción poco después de las doce',
        });
        expect(spanishSent.statusCode, 303);
        expect(
          spanishSent.headers['location']!.single,
          '/t/${report.publicToken}?answered=1&lang=es',
        );
        final saved = await ReportAnswer.db.find(s);
        expect(saved, hasLength(2));
        expect(
          saved.map((a) => a.question),
          everyElement(isNot(contains('¿'))),
        );
        await LostReport.db.updateRow(
          s,
          report.copyWith(status: ReportStatus.returned),
        );
        expect(
          (await call({
            'answer1': 'Some valid owner evidence',
            'answer2': 'Reception just after twelve',
          })).statusCode,
          409,
        );
        expect(await ReportAnswer.db.count(s), 2);
        final refusal = await call({
          'lang': 'es',
          'answer1': 'Some valid owner evidence',
          'answer2': 'Reception just after twelve',
        });
        expect(refusal.statusCode, 409);
        expect(
          await refusal.readAsString(),
          contains('El mostrador no está pidiendo respuestas'),
        );
        expect((await call(null, suffix: '/answer')).statusCode, 405);
      },
    );
  });
}
