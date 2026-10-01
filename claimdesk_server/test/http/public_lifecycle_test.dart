@Tags(['http'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

class _Auth implements ClientAuthKeyProvider {
  _Auth(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async =>
      wrapAsBearerAuthHeaderValue(token);
}

void main() {
  test(
    'Owner answers, pickup photo and permanent return work over HTTP',
    () async {
      final config = loadYaml(
        File('config/passwords.yaml').readAsStringSync(),
      )['development'];
      final client = Client(
            Platform.environment['PUBLIC_API_URL'] ?? 'http://localhost:8080/',
          ),
          web = http.Client();
      final site =
          Platform.environment['PUBLIC_WEB_URL'] ?? 'http://localhost:8082';
      try {
        final login = await client.emailIdp.login(
          email: 'staff@demo.claimdesk.local',
          password: config['demoStaffPassword'] as String,
        );
        client.authKeyProvider = _Auth(login.token);
        final venue = (await client.venue.myMemberships()).single.venueId;
        final front = (await client.venue.zones(
          venue,
        )).firstWhere((z) => z.name == 'Front desk');
        final upload = await client.item.requestPhotoUpload(venue, 'image/png');
        final bytes = await File(
          'test/fixtures/photos/generated_wooden_umbrella.png',
        ).readAsBytes();
        expect(
          await FileUploader(
            upload.uploadDescription,
          ).uploadByteData(ByteData.sublistView(bytes)),
          isTrue,
        );
        final item = await client.item.createItem(
          venue,
          CreateItemInput(
            itemId: upload.itemId,
            photoPath: upload.path,
            uploadProof: upload.proof,
            uploadExpiresAt: upload.expiresAt,
            zoneId: front.id,
            category: 'umbrella',
            colours: ['black', 'brown'],
            description:
                'A black folding umbrella with a curved wooden handle and chipped tip',
            privateNotes: 'Private HTTP item mark',
          ),
        );
        Future<T> until<T>(
          Future<T> Function() read,
          bool Function(T) ready,
        ) async {
          for (var n = 0; n < 160; n++) {
            final value = await read();
            if (ready(value)) return value;
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
          throw StateError('Lifecycle did not complete in time');
        }

        await until(
          () => client.item.getItem(item.id!),
          (FoundItem i) =>
              i.status == ItemStatus.unclaimed && i.embedding != null,
        );
        final request =
            http.Request('POST', Uri.parse('$site/v/hawrys-demo/lost'))
              ..followRedirects = false
              ..bodyFields = {
                'rawText':
                    'My black folding umbrella with a curved wooden handle and a small chip on the tip',
                'categoryHint': 'umbrella',
                'colour_black': 'on',
                'zoneId': front.id.toString(),
                'unsureDay': 'on',
                'contactEmail':
                    'lifecycle-${DateTime.now().microsecondsSinceEpoch}@example.test',
                'ownerOnlyDetails': 'Private HTTP owner proof',
                'consent': 'on',
              };
        final received = await web.send(request);
        await received.stream.drain<void>();
        expect(received.statusCode, 303);
        final ticket = Uri.parse(
          site,
        ).resolve(received.headers['location']!.split('?').first);
        final json =
            jsonDecode(
                  (await web.get(
                    ticket.resolve('${ticket.path}/status.json'),
                  )).body,
                )
                as Map;
        final report = await until(
          () => client.report.listReports(venue, ReportFilter()),
          (List<LostReport> rows) => rows.any(
            (r) =>
                r.refCode == json['refCode'] &&
                r.status == ReportStatus.searching,
          ),
        );
        final owner = report.firstWhere((r) => r.refCode == json['refCode']);
        final cards = await until(
          () => client.match.forReport(owner.id!),
          (List<MatchCard> rows) => rows.any((c) => c.item.id == item.id),
        );
        final match = cards.firstWhere((c) => c.item.id == item.id).match;
        await client.match.confirm(match.id!);
        final form = (await web.get(ticket)).body;
        expect(form.contains('Send answers'), isTrue);
        Future<http.StreamedResponse> answer(String first) async {
          final req =
              http.Request('POST', ticket.resolve('${ticket.path}/answer'))
                ..followRedirects = false
                ..bodyFields = {
                  'answer1': first,
                  'answer2': 'At the reception desk shortly after noon',
                };
          final response = await web.send(req);
          await response.stream.drain<void>();
          return response;
        }

        expect(
          (await answer(
            'The wooden handle has a small chip at its tip',
          )).statusCode,
          303,
        );
        expect((await client.match.answers(match.id!)).length, 2);
        final echo = (await web.get(ticket)).body;
        expect(echo.contains('The wooden handle has a small chip'), isTrue);
        await client.release.markReady(match.id!);
        final ready = await web.get(ticket);
        expect(ready.body.contains('Item ready for pickup'), isTrue);
        expect(ready.body.contains('Private HTTP'), isFalse);
        final photo = await web.get(ticket.resolve('${ticket.path}/photo'));
        expect(photo.statusCode, 200);
        expect(photo.headers['content-type']?.startsWith('image/jpeg'), isTrue);
        expect(photo.headers['cache-control'], 'no-store');
        final released = await client.release.release(
          item.id!,
          ReleaseInput(
            matchId: match.id,
            claimantName: 'Fictional HTTP collector',
            idTypeSeen: 'passport',
            detailsMatched: 2,
            describedBeforeViewing: true,
            thirdParty: false,
          ),
          null,
        );
        expect(released.record.reportId, owner.id);
        final returned = await web.get(ticket);
        expect(returned.body.contains('Return receipt'), isTrue);
        expect(returned.body.contains('Fictional HTTP collector'), isFalse);
        expect(
          returned.body.contains('The wooden handle has a small chip'),
          isFalse,
        );
        final receipt =
            jsonDecode(
                  (await web.get(
                    ticket.resolve('${ticket.path}/status.json'),
                  )).body,
                )
                as Map;
        expect(receipt['status'], 'returned');
        expect((receipt['receipt'] as Map).keys.toSet(), {
          'returnedAt',
          'idTypeSeen',
        });
        expect(
          (await web.get(ticket.resolve('${ticket.path}/photo'))).statusCode,
          404,
        );
        expect(
          (await answer(
            'The wooden handle has a small chip at its tip',
          )).statusCode,
          409,
        );
        await expectLater(
          client.release.release(
            item.id!,
            ReleaseInput(
              claimantName: 'Demo collector',
              idTypeSeen: 'passport',
              detailsMatched: 2,
              describedBeforeViewing: true,
              thirdParty: false,
            ),
            null,
          ),
          throwsA(isA<AlreadyReleasedException>()),
        );
      } finally {
        client.close();
        web.close();
      }
    },
    skip: Platform.environment['RUN_PUBLIC_HTTP'] != 'true',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
