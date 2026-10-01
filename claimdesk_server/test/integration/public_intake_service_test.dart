import 'dart:math';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/services/public_codes.dart';
import 'package:claimdesk_server/src/services/public_intake_service.dart';
import 'package:claimdesk_server/src/web/public/report_form_input.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

ReportFormInput input({
  String? category = 'umbrella',
  String text = 'A black folding umbrella with a wooden handle',
  String email = 'owner@example.test',
}) => ReportFormInput(
  rawText: text,
  categoryHint: category,
  colourHints: ['black'],
  contactEmail: email,
  lostAt: DateTime.now().toUtc(),
  lostAtFuzzyDays: 7,
  ownerOnlyDetails: 'Private mark',
);
void main() {
  withServerpod('Public report intake', (builder, _) {
    late Venue venue;
    late Session s;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
    });
    test(
      'received report stores credentials privately and posts audit and event',
      () async {
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        try {
          final result = await PublicIntakeService().submit(
            s,
            venue,
            input(),
            'salted-address-hash',
          );
          await flushEventQueue();
          expect(result.duplicate, isFalse);
          expect(result.report.status, ReportStatus.received);
          expect(result.report.refCode, hasLength(6));
          expect(result.report.publicToken, hasLength(22));
          expect(result.report.ipHash, 'salted-address-hash');
          expect(events.single.kind, 'reportCreated');
          final audit = await AuditEvent.db.findFirstRow(
            s,
            where: (t) => t.entityId.equals(result.report.id!),
          );
          expect(audit!.payload!.data, {'refCode': result.report.refCode});
          expect(audit.payload.toString(), isNot(contains('Private mark')));
        } finally {
          await sub.cancel();
        }
      },
    );
    test(
      'duplicate touches the existing ticket while different categories and text insert',
      () async {
        final service = PublicIntakeService();
        final first = await service.submit(s, venue, input(), 'hash');
        final again = await service.submit(
          s,
          venue,
          input(text: 'Different wording but same umbrella category'),
          'hash',
        );
        expect(again.duplicate, isTrue);
        expect(again.report.id, first.report.id);
        expect(await LostReport.db.count(s), 1);
        final second = await service.submit(
          s,
          venue,
          input(
            category: 'phone',
            text: 'My silver mobile telephone has a cracked screen',
          ),
          'hash',
        );
        expect(second.duplicate, isFalse);
        expect(await LostReport.db.count(s), 2);
        final otherOwner = await service.submit(
          s,
          venue,
          input(email: 'second@example.test'),
          'hash',
        );
        expect(otherOwner.duplicate, isFalse);
      },
    );
    test(
      'unknown and malformed tokens are refused and collision is retried',
      () async {
        final next = PublicCodes(random: Random(7));
        final taken = next.reference();
        await makeReport(
          s,
          venue.id!,
          refCode: taken,
          publicToken: PublicCodes().token(),
        );
        final service = PublicIntakeService(
          codes: PublicCodes(random: Random(7)),
        );
        final result = await service.submit(s, venue, input(), 'hash');
        expect(result.report.refCode, isNot(taken));
        expect(
          (await service.findByToken(s, result.report.publicToken))!.id,
          result.report.id,
        );
        expect(await service.findByToken(s, 'bad'), isNull);
        expect(await service.findByToken(s, 'Z' * 22), isNull);
      },
    );
  });
}
