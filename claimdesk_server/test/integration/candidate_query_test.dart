@Tags(['integration'])
library;

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/matching/candidate_query.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Hybrid candidates', (builder, _) {
    late Session s;
    late Venue venue;
    late LostReport report;
    final at = DateTime.utc(2026, 9, 30, 12);
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      report = await makeReport(s, venue.id!);
      report = await LostReport.db.updateRow(
        s,
        report.copyWith(lostAt: at, createdAt: at, embedding: unitVector(1, 0)),
      );
    });
    Future<FoundItem> item(
      String ref, {
      String? caption = 'black umbrella wooden handles',
      Vector? embedding,
      ItemStatus status = ItemStatus.unclaimed,
      DateTime? found,
      UuidValue? venueId,
    }) async => FoundItem.db.insertRow(
      s,
      FoundItem(
        venueId: venueId ?? venue.id!,
        refCode: ref,
        captionText: caption,
        embedding: embedding,
        status: status,
        foundAt: found ?? at,
        loggedByAuthUserId: actorId,
      ),
    );
    test(
      'hard filters exclude foreign, unavailable and out-of-window items',
      () async {
        final good = await item('GOOD01', embedding: unitVector(1, 0));
        await item(
          'BUSY01',
          embedding: unitVector(1, 0),
          status: ItemStatus.matched,
        );
        await item(
          'OLD001',
          embedding: unitVector(1, 0),
          found: at.subtract(const Duration(days: 3)),
        );
        await item(
          'LATE01',
          embedding: unitVector(1, 0),
          found: at.add(const Duration(days: 46)),
        );
        final other = await makeVenue(s, slug: 'other-desk');
        await item('OTHER1', venueId: other.id!, embedding: unitVector(1, 0));
        await item('EMPTY1', caption: null);
        final result = await CandidateQuery(now: () => at).forReport(s, report);
        expect(result.map((c) => c.item.id), [good.id]);
        expect(result.single.cosSim, closeTo(1, .000001));
      },
    );
    test(
      'lexical leg covers partial terms and stems handles without needing a vector',
      () async {
        final lex = await item('LEX001');
        final vec = await item(
          'VEC001',
          caption: 'silent unrelated object',
          embedding: unitVector(1, 0),
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(rawText: 'the black umbrella wooden handle'),
        );
        final result = await CandidateQuery().forReport(s, report);
        expect(result.map((c) => c.item.id).toSet(), {lex.id, vec.id});
        final row = result.firstWhere((c) => c.item.id == lex.id);
        expect(row.cosSim, isNull);
        expect(row.keywordCoverage, 1);
        expect(
          row.matchedKeywords,
          containsAll(['black', 'umbrella', 'wooden', 'handl']),
        );
        expect(
          result.firstWhere((c) => c.item.id == vec.id).keywordCoverage,
          0,
        );
      },
    );
    test(
      'vector leg orders cosine, excludes nulls and limits its union to 25 without lexical overlap',
      () async {
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(rawText: 'zzzzzzz'),
        );
        final best = await item(
          'BEST01',
          caption: null,
          embedding: unitVector(1, 0),
        );
        for (var i = 0; i < 30; i++) {
          await item(
            'V${i.toString().padLeft(5, '0')}',
            caption: null,
            embedding: unitVector(1, i + 1),
          );
        }
        await item('NULL01', caption: null);
        final result = await CandidateQuery().forReport(s, report);
        expect(result, hasLength(25));
        expect(result.first.item.id, best.id);
        expect(
          result.map((c) => c.cosSim!),
          orderedEquals(
            result.map((c) => c.cosSim!).toList()
              ..sort((a, b) => b.compareTo(a)),
          ),
        );
      },
    );
    test(
      'union deduplicates and fuzz and unknown dates use their distinct windows',
      () async {
        final a = await item(
          'FUZZ01',
          embedding: unitVector(1, 0),
          found: at.subtract(const Duration(days: 8)),
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(lostAtFuzzyDays: 7),
        );
        expect(
          (await CandidateQuery().forReport(s, report)).map((c) => c.item.id),
          [a.id],
        );
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(lostAt: null),
        );
        final old = await item(
          'WIDE01',
          embedding: unitVector(1, 0),
          found: at.subtract(const Duration(days: 59)),
        );
        await item(
          'OLD002',
          embedding: unitVector(1, 0),
          found: at.subtract(const Duration(days: 61)),
        );
        await item(
          'FUTURE',
          embedding: unitVector(1, 0),
          found: at.add(const Duration(days: 1)),
        );
        expect(
          (await CandidateQuery(
            now: () => at,
          ).forReport(s, report)).map((c) => c.item.id).toSet(),
          {a.id, old.id},
        );
      },
    );
    test(
      'item direction includes open reports in widened windows and excludes closed and old undated reports',
      () async {
        final found = await item('REVERSE', embedding: unitVector(1, 0));
        report = await LostReport.db.updateRow(
          s,
          report.copyWith(status: ReportStatus.possibleMatch),
        );
        final unknown = await makeReport(
          s,
          venue.id!,
          refCode: 'UNDATE',
          publicToken: 'undated',
        );
        await LostReport.db.updateRow(
          s,
          unknown.copyWith(createdAt: at.subtract(const Duration(days: 59))),
        );
        final closed = await makeReport(
          s,
          venue.id!,
          refCode: 'CLOSED',
          publicToken: 'closed',
        );
        await LostReport.db.updateRow(
          s,
          closed.copyWith(
            status: ReportStatus.closed,
            lostAt: at,
            embedding: unitVector(1, 0),
          ),
        );
        final old = await makeReport(
          s,
          venue.id!,
          refCode: 'OLDREP',
          publicToken: 'old',
        );
        await LostReport.db.updateRow(
          s,
          old.copyWith(createdAt: at.subtract(const Duration(days: 61))),
        );
        final result = await CandidateQuery().forItem(s, found);
        expect(result.map((c) => c.report.id).toSet(), {report.id, unknown.id});
        expect(result.first.report.id, report.id);
      },
    );
    test('stop words alone provide no lexical evidence', () async {
      await item('STOP01', embedding: unitVector(1, 0));
      report = await LostReport.db.updateRow(
        s,
        report.copyWith(rawText: 'the and or'),
      );
      expect(
        (await CandidateQuery().forReport(s, report)).single.keywordCoverage,
        isNull,
      );
    });
  });
}
