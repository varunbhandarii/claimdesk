import 'dart:convert';

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given stored structured data', (builder, _) {
    late Session s;
    late Venue venue;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
    });

    test(
      'when an item is read then attributes, flags and vector round trip',
      () async {
        final attributes = ItemAttributes(
          category: 'umbrella',
          categoryConfidence: .95,
          colours: ['black', 'brown'],
          marks: ['chip on handle'],
          brand: 'Fictional',
          material: 'wood',
          description: 'Black umbrella with a wooden handle',
          containsPersonalData: true,
          personalDataKinds: ['name'],
          imageQuality: 'good',
          keywords: ['umbrella', 'wooden'],
          language: 'en',
          source: 'test',
          modelId: 'fixture',
          promptVersion: '1',
        );
        final inserted = await FoundItem.db.insertRow(
          s,
          FoundItem(
            venueId: venue.id!,
            refCode: 'ROUND1',
            loggedByAuthUserId: actorId,
            attributes: attributes,
            restricted: true,
            embedding: unitVector(3, 4),
            embeddingModel: 'test-1536',
          ),
        );
        final stored = (await FoundItem.db.findById(s, inserted.id!))!;
        expect(stored.attributes!.toJson(), attributes.toJson());
        expect(stored.restricted, isTrue);
        expect(
          stored.embedding!.toList(),
          orderedEquals(
            inserted.embedding!.toList().map((v) => closeTo(v, 1e-6)),
          ),
        );
        expect(stored.embedding!.toList(), hasLength(1536));
        final wire = FoundItem.fromJson(
          jsonDecode(jsonEncode(stored.toJson())),
        );
        expect(wire.toJson(), stored.toJson());
      },
    );

    test(
      'when a match is read then its complete explanation round trips',
      () async {
        final item = await makeItem(s, venue.id!);
        final report = await makeReport(s, venue.id!);
        final match = await makeMatch(s, item, report);
        final stored = (await ItemMatch.db.findById(s, match.id!))!;
        expect(stored.explanation.toJson(), explanation().toJson());
        expect(stored.state, MatchState.pending);
        expect(
          ItemMatch.fromJson(jsonDecode(jsonEncode(stored.toJson()))).toJson(),
          stored.toJson(),
        );
      },
    );

    test(
      'when a report is read then its attributes and vector round trip',
      () async {
        var report = await makeReport(s, venue.id!);
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(
            attributes: ItemAttributes(
              category: 'umbrella',
              colours: ['black'],
              marks: [],
              description: 'Black umbrella',
              personalDataKinds: [],
              keywords: ['umbrella'],
              source: 'test',
            ),
            embedding: unitVector(1, 0),
            embeddingModel: 'test-1536',
          ),
        );
        final stored = (await LostReport.db.findById(s, report.id!))!;
        expect(stored.attributes!.toJson(), report.attributes!.toJson());
        expect(stored.embedding!.toList(), report.embedding!.toList());
      },
    );

    test(
      'when anonymous jobs are inserted then multiple null identifiers are allowed',
      () async {
        for (var i = 0; i < 2; i++) {
          await WorkItem.db.insertRow(
            s,
            WorkItem(
              kind: 'nightly',
              runAt: DateTime.utc(2026),
              payload: WorkPayload(data: {'key': 'value'}),
            ),
          );
        }
        final rows = await WorkItem.db.find(s);
        expect(rows, hasLength(2));
        expect(
          rows.every((r) => r.identifier == null && r.venueId == null),
          isTrue,
        );
        expect(rows.first.payload.data, {'key': 'value'});
        expect(rows.first.state, WorkState.pending);
        expect(rows.first.maxAttempts, 5);
      },
    );

    test(
      'when a named job repeats then its idempotency key is rejected',
      () async {
        final work = WorkItem(
          kind: 'caption',
          venueId: venue.id!,
          identifier: 'caption_1',
          runAt: DateTime.utc(2026),
          payload: WorkPayload(data: {}),
        );
        await WorkItem.db.insertRow(s, work);
        await expectLater(
          WorkItem.db.insertRow(s, work),
          throwsA(isA<DatabaseUniqueViolationException>()),
        );
      },
    );

    test(
      'when cosine ordering is used then the nearest of three items is first',
      () async {
        await makeItem(
          s,
          venue.id!,
          refCode: 'far',
          embedding: unitVector(-1, 0),
        );
        await makeItem(
          s,
          venue.id!,
          refCode: 'middle',
          embedding: unitVector(0, 1),
        );
        await makeItem(
          s,
          venue.id!,
          refCode: 'near',
          embedding: unitVector(1, 0),
        );
        final rows = await FoundItem.db.find(
          s,
          where: (t) => t.venueId.equals(venue.id!),
          orderBy: (t) => t.embedding.distanceCosine(unitVector(1, 0)),
        );
        expect(rows.map((r) => r.refCode), ['near', 'middle', 'far']);
      },
    );
  });

  test(
    'when events and errors cross the wire then types and ids are preserved',
    () {
      final event = DeskEvent(
        kind: 'itemChanged',
        venueId: actorId,
        itemId: actorId,
        at: DateTime.utc(2026),
      );
      expect(
        DeskEvent.fromJson(jsonDecode(jsonEncode(event.toJson()))).toJson(),
        event.toJson(),
      );
      final membership = NotAMemberException(
        message: 'Denied',
        venueId: actorId,
      );
      expect(
        NotAMemberException.fromJson(
          jsonDecode(jsonEncode(membership.toJson())),
        ).venueId,
        actorId,
      );
      final release = AlreadyReleasedException(
        message: 'Released',
        itemId: actorId,
      );
      expect(
        AlreadyReleasedException.fromJson(
          jsonDecode(jsonEncode(release.toJson())),
        ).itemId,
        actorId,
      );
    },
  );
}
