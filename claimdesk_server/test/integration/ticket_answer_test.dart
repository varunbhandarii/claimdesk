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
        expect((await call(null, suffix: '/answer')).statusCode, 405);
      },
    );
  });
}
