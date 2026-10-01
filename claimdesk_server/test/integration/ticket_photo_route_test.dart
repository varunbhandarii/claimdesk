@Tags(['integration'])
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/child_records.dart';
import 'package:claimdesk_server/src/web/public/ticket_photo_route.dart';
import 'package:claimdesk_server/src/web/public/ticket_route.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Private pickup photo and receipt', (builder, _) {
    test(
      'Only ready unrestricted reservations expose a thumbnail; receipts contain no identifying text',
      () async {
        final s = builder.build(), venue = await makeVenue(builder.build());
        final path = 'tests/${const Uuid().v4()}.jpg';
        final bytes = Uint8List.fromList([255, 216, 255, 217]);
        await s.storage.storeFile(
          storageId: 'private',
          path: path,
          byteData: ByteData.sublistView(bytes),
        );
        try {
          var item = await makeItem(s, venue.id!);
          item = await FoundItem.db.updateRow(
            s,
            item.copyWith(
              status: ItemStatus.matched,
              thumbPath: path,
              privateNotes: 'PRIVATE-NOTES',
              captionText: 'PRIVATE-CAPTION',
            ),
          );
          var report = await makeReport(
            s,
            venue.id!,
            publicToken: 'abcdefghijklmnopqrstuv',
          );
          final match = await makeMatch(s, item, report);
          await ItemMatch.db.updateRow(
            s,
            match.copyWith(state: MatchState.confirmed),
          );
          await ChildRecords.answer(
            s,
            matchId: match.id!,
            question: 'PRIVATE-QUESTION',
            answer: 'PRIVATE-ANSWER',
          );
          await templates.loadAll(Directory('web/templates'));
          final router = RelicRouter();
          router.get(
            '/t/:token/photo',
            (req) => TicketPhotoRoute().handleCall(s, req),
          );
          router.get('/t/:token', (req) => TicketRoute().handleCall(s, req));
          router.get(
            '/t/:token/status.json',
            (req) => TicketJsonRoute().handleCall(s, req),
          );
          Future<Response> call(String suffix) async =>
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
          for (final state in ReportStatus.values) {
            report = await LostReport.db.updateRow(
              s,
              report.copyWith(status: state),
            );
            final response = await call('/photo');
            expect(
              response.statusCode,
              state == ReportStatus.readyForPickup ? 200 : 404,
            );
            expect(response.headers['cache-control'], ['no-store']);
            if (state == ReportStatus.readyForPickup) {
              expect(
                await response.read().expand((chunk) => chunk).toList(),
                bytes,
              );
            }
            final html = await (await call('')).readAsString();
            final json = await (await call('/status.json')).readAsString();
            expect(
              html.contains('Item ready for pickup'),
              state == ReportStatus.readyForPickup,
            );
            for (final secret in [
              'PRIVATE-NOTES',
              'PRIVATE-CAPTION',
              'PRIVATE-ANSWER',
              path,
            ]) {
              expect(html, isNot(contains(secret)));
              expect(json, isNot(contains(secret)));
            }
          }
          report = await LostReport.db.updateRow(
            s,
            report.copyWith(status: ReportStatus.readyForPickup),
          );
          await FoundItem.db.updateRow(s, item.copyWith(restricted: true));
          expect((await call('/photo')).statusCode, 404);
          await FoundItem.db.updateRow(s, item.copyWith(thumbPath: null));
          expect((await call('/photo')).statusCode, 404);
          await FoundItem.db.updateRow(
            s,
            item.copyWith(thumbPath: 'missing-thumbnail'),
          );
          expect((await call('/photo')).statusCode, 404);
          final receipt = await ChildRecords.release(
            s,
            itemId: item.id!,
            reportId: report.id,
            claimantName: 'PRIVATE-CLAIMANT',
            idTypeSeen: 'passport',
            detailsMatched: 2,
            describedBeforeViewing: true,
            releasedByAuthUserId: actorId,
            thirdPartyAuthorisationNote: 'PRIVATE-AUTHORISATION',
          );
          report = await LostReport.db.updateRow(
            s,
            report.copyWith(
              status: ReportStatus.returned,
              closedAt: receipt.releasedAt,
            ),
          );
          final json =
              jsonDecode(await (await call('/status.json')).readAsString())
                  as Map;
          expect((json['receipt'] as Map).keys.toSet(), {
            'returnedAt',
            'idTypeSeen',
          });
          final html = await (await call('')).readAsString();
          expect(html, contains('Return receipt'));
          expect(html, contains('Passport'));
          for (final secret in [
            'PRIVATE-CLAIMANT',
            'PRIVATE-AUTHORISATION',
            'PRIVATE-ANSWER',
          ]) {
            expect(html, isNot(contains(secret)));
            expect(jsonEncode(json), isNot(contains(secret)));
          }
        } finally {
          await s.storage.deleteFile(storageId: 'private', path: path);
        }
      },
    );
  });
}
