@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/web/public/ticket_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Private matching ticket', (builder, _) {
    test(
      'HTML and JSON explain matching states without exposing item or proposal details',
      () async {
        final s = builder.build();
        final venue = await makeVenue(s);
        await templates.loadAll(Directory('web/templates'));
        var report = await makeReport(
          s,
          venue.id!,
          publicToken: 'abcdefghijklmnopqrstuv',
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(
            rawText: 'private-report-description',
            ownerOnlyDetails: 'private-owner-proof',
            contactEmail: 'private@example.test',
          ),
        );
        final item = await makeItem(s, venue.id!, refCode: 'PRIVATEITEM');
        final match = await makeMatch(s, item, report);
        final router = RelicRouter();
        router.get('/t/:token', (req) => TicketRoute().handleCall(s, req));
        router.get(
          '/t/:token/status.json',
          (req) => TicketJsonRoute().handleCall(s, req),
        );
        for (final state in [
          ReportStatus.searching,
          ReportStatus.possibleMatch,
        ]) {
          await LostReport.db.updateRow(s, report.copyWith(status: state));
          Future<String> body(String suffix) async {
            final response =
                await router(
                      RequestInternal.create(
                        Method.get,
                        Uri.parse(
                          'http://localhost/t/${report.publicToken}$suffix',
                        ),
                        Object(),
                      ),
                    )
                    as Response;
            expect(response.statusCode, 200);
            return response.readAsString();
          }

          final html = await body(''), rawJson = await body('/status.json');
          final json = jsonDecode(rawJson) as Map;
          expect(json['status'], state.name);
          final sentence = state == ReportStatus.searching
              ? 'we keep checking as new items arrive'
              : 'Come to the desk with photo ID';
          expect(html, contains(sentence));
          expect(json['sentence'], contains(sentence));
          for (final secret in [
            report.publicToken,
            report.rawText,
            report.ownerOnlyDetails!,
            report.contactEmail!,
            item.refCode,
            item.id.toString(),
            match.id.toString(),
          ]) {
            expect(html, isNot(contains(secret)));
            expect(rawJson, isNot(contains(secret)));
          }
          expect(json.keys.toSet(), {
            'refCode',
            'status',
            'sentence',
            'filedAt',
            'updatedAt',
            'venue',
          });
        }
      },
    );
  });
}
