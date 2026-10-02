@Tags(['integration'])
library;

import 'dart:async';
import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/ai/providers.dart';
import 'package:claimdesk_server/src/ai/report_normaliser.dart';
import 'package:claimdesk_server/src/ai/text_template.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/handlers/match_report_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/match_item_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/caption_item_handler.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:claimdesk_server/src/matching/match_jobs.dart';
import 'package:claimdesk_server/src/services/public_intake_service.dart';
import 'package:claimdesk_server/src/web/public/report_form_input.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

class CountingNormaliser extends HintNormaliser {
  int calls = 0;
  @override
  Future<NormaliseResult> normalise(String rawText, ReportHints hints) {
    calls++;
    return super.normalise(rawText, hints);
  }
}

class CountingEmbedder extends FakeEmbedder {
  int queries = 0;
  @override
  Future<List<double>> embedQuery(String text) {
    queries++;
    return super.embedQuery(text);
  }
}

class DelayedNormaliser implements ReportNormaliser {
  final result = Completer<NormaliseResult>();
  @override
  String get id => 'delayed';
  @override
  Future<NormaliseResult> normalise(String rawText, ReportHints hints) =>
      result.future;
}

void main() {
  withServerpod('Durable matching', (builder, _) {
    setUp(() => clearWorkerTestData(builder.build()));
    tearDown(() => clearWorkerTestData(builder.build()));
    late Session s;
    late Venue venue;
    late CountingNormaliser normaliser;
    late CountingEmbedder embedder;
    late JobWorker worker;
    setUp(() async {
      s = builder.build();
      venue = await makeVenue(s);
      normaliser = CountingNormaliser();
      embedder = CountingEmbedder();
      Providers.normaliser = normaliser;
      Providers.embedder = embedder;
      worker = JobWorker(
        s.serverpod,
        handlers: [
          MatchReportHandler(),
          MatchItemHandler(),
          CaptionItemHandler(),
        ],
        renewLeases: false,
      );
    });
    Future<LostReport> submit() async => (await PublicIntakeService().submit(
      s,
      venue,
      ReportFormInput(
        rawText: 'black umbrella with a wooden handle',
        categoryHint: 'umbrella',
        colourHints: ['black'],
        contactEmail: 'owner@example.test',
        lostAt: DateTime.now().toUtc(),
        lostAtFuzzyDays: 0,
      ),
      'hash',
    )).report;
    Future<FoundItem> shelf(String ref) async {
      final attrs = (await normaliser.normalise(
        'black umbrella with a wooden handle',
        const ReportHints(categoryHint: 'umbrella', colourHints: ['black']),
      )).attributes!;
      return FoundItem.db.insertRow(
        s,
        FoundItem(
          venueId: venue.id!,
          refCode: ref,
          status: ItemStatus.unclaimed,
          attributes: attrs,
          captionText: TextTemplate.render(attrs),
          embedding: Vector(
            await embedder.embedDocument(TextTemplate.render(attrs)),
          ),
          embeddingModel: embedder.modelId,
          loggedByAuthUserId: actorId,
        ),
      );
    }

    test(
      'report and enqueue commit together and duplicates do not reset queued work',
      () async {
        final report = await submit();
        final job = (await WorkItem.db.find(s)).single;
        expect(job.kind, 'match_report');
        expect(job.payload.entityId, report.id);
        expect(job.venueId, report.venueId);
        expect(job.maxAttempts, 4);
        await submit();
        expect(await LostReport.db.count(s), 1);
        expect(await WorkItem.db.count(s), 1);
        expect(
          (await WorkItem.db.findById(s, job.id!))!.updatedAt,
          job.updatedAt,
        );
      },
    );
    test(
      'enqueue failure rolls back both report and its creation audit',
      () async {
        addTearDown(
          () => s.db.unsafeSimpleExecute(
            'ALTER TABLE work_item DROP CONSTRAINT IF EXISTS no_matching',
          ),
        );
        await s.db.unsafeSimpleExecute(
          "ALTER TABLE work_item ADD CONSTRAINT no_matching CHECK (kind <> 'match_report')",
        );
        await expectLater(submit(), throwsA(isA<DatabaseQueryException>()));
        expect(await LostReport.db.count(s), 0);
        expect(await AuditEvent.db.count(s), 0);
      },
    );
    test(
      'normalise and embed once then rank explain search and emit only visible new proposals',
      () async {
        final item = await shelf('ITEM01');
        normaliser.calls = 0;
        final report = await submit();
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        try {
          final claim = (await worker.claim(s))!;
          await MatchReportHandler().run(s, claim);
          await flushEventQueue();
          final updated = (await LostReport.db.findById(s, report.id!))!;
          expect(updated.status, ReportStatus.searching);
          expect(updated.attributes!.source, 'report_hints');
          expect(updated.embedding!.toList(), hasLength(1536));
          final match = (await ItemMatch.db.find(s)).single;
          expect(match.itemId, item.id);
          expect(match.rank, 1);
          expect(match.label, 'strong');
          expect(match.explanation.category, 1);
          expect(match.explanation.cosSim, closeTo(1, 1e-6));
          expect(events.map((e) => e.kind), [
            'matchCreated',
            'reportStatus',
            'matchStatus',
            'reportStatus',
          ]);
          await MatchReportHandler().run(s, claim);
          await flushEventQueue();
          expect(normaliser.calls, 1);
          expect(embedder.queries, 1);
          expect(await ItemMatch.db.count(s), 1);
          expect(events.where((e) => e.kind == 'matchCreated'), hasLength(1));
          expect(events.where((e) => e.kind == 'reportStatus'), hasLength(3));
          await ItemMatch.db.updateRow(
            s,
            match.copyWith(state: MatchState.confirmed, score: .99),
          );
          await MatchReportHandler().run(s, claim);
          expect(
            (await ItemMatch.db.findById(s, match.id!))!.state,
            MatchState.confirmed,
          );
          expect((await ItemMatch.db.findById(s, match.id!))!.score, .99);
        } finally {
          await sub.cancel();
        }
      },
    );
    Future<List<ItemMatch>> drafts(UuidValue reportId) async {
      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (DateTime.now().isBefore(deadline)) {
        final rows = await ItemMatch.db.find(
          s,
          where: (t) => t.reportId.equals(reportId),
        );
        if (rows.isNotEmpty &&
            rows.every((r) => r.algorithmVersion == 'v1-draft')) {
          return rows;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail(
        'Draft rows did not become available while normalisation was blocked',
      );
    }

    test(
      'drafts search before Claude completes; refinement updates IDs and removes dropped rows',
      () async {
        final a = await shelf('ITEM01'), b = await shelf('ITEM02');
        final report = await submit();
        final delayed = DelayedNormaliser();
        Providers.normaliser = delayed;
        final claim = (await worker.claim(s))!;
        final events = <DeskEvent>[];
        final sub = s.messages
            .createStream<DeskEvent>('venue_${venue.id}')
            .listen(events.add);
        final run = MatchReportHandler().run(s, claim);
        try {
          final preliminary = await drafts(report.id!);
          expect(preliminary, hasLength(2));
          expect(delayed.result.isCompleted, false);
          final searching = (await LostReport.db.findById(s, report.id!))!;
          expect(searching.status, ReportStatus.searching);
          expect(searching.attributes, isNull);
          expect(searching.embedding, isNull);
          expect(
            await AuditEvent.db.count(
              s,
              where: (t) => t.action.equals('match_completed'),
            ),
            0,
          );
          await FoundItem.db.updateRow(
            s,
            b.copyWith(status: ItemStatus.disposed),
          );
          delayed.result.complete(
            NormaliseResult(
              outcome: 'ok',
              attributes: a.attributes!.copyWith(
                source: 'report_llm',
                modelId: 'test-refined',
                marks: ['curved wooden handle'],
              ),
            ),
          );
          await run;
          await flushEventQueue();
          final finalRow = (await ItemMatch.db.find(s)).single;
          expect(
            finalRow.id,
            preliminary.singleWhere((r) => r.itemId == a.id).id,
          );
          expect(finalRow.algorithmVersion, 'v1');
          expect(
            (await LostReport.db.findById(s, report.id!))!.attributes!.source,
            'report_llm',
          );
          expect(embedder.queries, 2);
          expect(
            await AuditEvent.db.count(
              s,
              where: (t) => t.action.equals('match_completed'),
            ),
            1,
          );
          expect(events.map((e) => e.kind), [
            'matchCreated',
            'matchCreated',
            'reportStatus',
            'matchStatus',
            'reportStatus',
          ]);
        } finally {
          if (!delayed.result.isCompleted) {
            delayed.result.completeError(StateError('cleanup'));
          }
          await run.catchError((Object _) {});
          await sub.cancel();
        }
      },
    );
    test(
      'a failure after the draft is recoverable without duplicates; hint fallback embeds once',
      () async {
        await shelf('ITEM01');
        final report = await submit();
        final delayed = DelayedNormaliser();
        Providers.normaliser = delayed;
        final claim = (await worker.claim(s))!;
        final run = MatchReportHandler().run(s, claim);
        final failure = expectLater(run, throwsStateError);
        final preliminary = await drafts(report.id!);
        delayed.result.completeError(
          StateError('injected crash between passes'),
        );
        await failure;
        expect(
          (await LostReport.db.findById(s, report.id!))!.attributes,
          isNull,
        );
        Providers.normaliser = HintNormaliser();
        embedder.queries = 0;
        await MatchReportHandler().run(s, claim);
        final refined = (await ItemMatch.db.find(s)).single;
        expect(refined.id, preliminary.single.id);
        expect(refined.algorithmVersion, 'v1');
        expect(embedder.queries, 1);
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) => t.action.equals('match_completed'),
          ),
          1,
        );
      },
    );
    test('a decision made on a draft survives refinement unchanged', () async {
      final item = await shelf('ITEM01');
      final report = await submit();
      final delayed = DelayedNormaliser();
      Providers.normaliser = delayed;
      final claim = (await worker.claim(s))!;
      final run = MatchReportHandler().run(s, claim);
      final preliminary = (await drafts(report.id!)).single;
      await ItemMatch.db.updateRow(
        s,
        preliminary.copyWith(state: MatchState.confirmed, score: .98),
      );
      delayed.result.complete(
        NormaliseResult(outcome: 'ok', attributes: item.attributes!),
      );
      await run;
      final decided = (await ItemMatch.db.findById(s, preliminary.id!))!;
      expect(decided.state, MatchState.confirmed);
      expect(decided.score, .98);
      expect(decided.algorithmVersion, 'v1-draft');
    });
    test(
      'stale pending proposals are removed while decided rows survive',
      () async {
        final a = await shelf('ITEM01'), b = await shelf('ITEM02');
        await submit();
        final claim = (await worker.claim(s))!;
        await MatchReportHandler().run(s, claim);
        final rows = await ItemMatch.db.find(s);
        final decided = rows.firstWhere((r) => r.itemId == a.id);
        await ItemMatch.db.updateRow(
          s,
          decided.copyWith(state: MatchState.rejected),
        );
        await FoundItem.db.updateRow(
          s,
          b.copyWith(status: ItemStatus.disposed),
        );
        await MatchReportHandler().run(s, claim);
        expect((await ItemMatch.db.find(s)).single.id, decided.id);
      },
    );
    test(
      'embedding failure retries persisted normalisation and final failure audits availability',
      () async {
        final report = await submit();
        embedder.fail = true;
        var claim = (await worker.claim(s))!;
        await expectLater(MatchReportHandler().run(s, claim), throwsStateError);
        expect(
          (await LostReport.db.findById(s, report.id!))!.attributes,
          isNotNull,
        );
        expect(
          (await LostReport.db.findById(s, report.id!))!.status,
          ReportStatus.received,
        );
        await WorkItem.db.updateRow(
          s,
          claim.copyWith(state: WorkState.pending, maxAttempts: 1, attempts: 0),
        );
        await worker.tick(s);
        claim = (await WorkItem.db.findById(s, claim.id!))!;
        expect(claim.state, WorkState.failed);
        expect(normaliser.calls, 1);
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) => t.action.equals('match_failed'),
          ),
          1,
        );
      },
    );
    test(
      'reverse direction adds an item to an open report without calling either provider',
      () async {
        final report = await submit();
        await worker.tick(s);
        final item = await shelf('ITEM01');
        normaliser.calls = 0;
        embedder.queries = 0;
        await MatchJobs.item(s, item);
        await worker.tick(s);
        expect((await ItemMatch.db.find(s)).single.reportId, report.id);
        expect(normaliser.calls, 0);
        expect(embedder.queries, 0);
        expect(
          (await FoundItem.db.findById(s, item.id!))!.status,
          ItemStatus.unclaimed,
        );
      },
    );
    test(
      'reverse skips captioning and vectorless items and closed reports',
      () async {
        final report = await submit();
        await worker.tick(s);
        final item = await shelf('ITEM01');
        final captioning = await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.captioning),
        );
        await MatchJobs.item(s, captioning);
        await worker.tick(s);
        expect(await ItemMatch.db.count(s), 0);
        final vectorless = await FoundItem.db.updateRow(
          s,
          item.copyWith(embedding: null),
        );
        await MatchJobs.item(s, vectorless);
        await worker.tick(s);
        expect(await ItemMatch.db.count(s), 0);
        await FoundItem.db.updateRow(s, item);
        final row = (await LostReport.db.findById(s, report.id!))!;
        await LostReport.db.updateRow(
          s,
          row.copyWith(status: ReportStatus.closed),
        );
        await MatchJobs.item(s, item);
        await worker.tick(s);
        expect(await ItemMatch.db.count(s), 0);
      },
    );
    test(
      'caption completion queues reverse matching only after a vector exists',
      () async {
        final item = await shelf('ITEM01');
        final waiting = await FoundItem.db.updateRow(
          s,
          item.copyWith(status: ItemStatus.captioning, embedding: null),
        );
        await WorkItem.db.insertRow(
          s,
          WorkItem(
            venueId: venue.id!,
            kind: 'caption_item',
            runAt: DateTime.now().toUtc(),
            payload: WorkPayload(entityId: waiting.id, data: {}),
          ),
        );
        final claim = (await worker.claim(s))!;
        await CaptionItemHandler().run(s, claim);
        final reverse = await WorkItem.db.findFirstRow(
          s,
          where: (t) => t.kind.equals('match_item'),
        );
        expect(reverse!.venueId, venue.id);
        expect(reverse.maxAttempts, 3);
        expect(
          (await FoundItem.db.findById(s, item.id!))!.embedding,
          isNotNull,
        );
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
