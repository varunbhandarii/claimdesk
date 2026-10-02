@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/ai/providers.dart';
import 'package:claimdesk_server/src/ai/report_normaliser.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:claimdesk_server/src/jobs/handlers/caption_item_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/match_item_handler.dart';
import 'package:claimdesk_server/src/jobs/handlers/match_report_handler.dart';
import 'package:claimdesk_server/src/services/demo_inventory_service.dart';
import 'package:claimdesk_server/src/seed/demo_inventory.dart';
import 'package:test/test.dart';
import 'test_tools/fixtures.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

void main() {
  test('deployable demo bundle equals the reviewed fixture selections', () {
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/matching/synthetic_v1.json',
              ).readAsStringSync(),
            )
            as Map;
    final bundle = jsonDecode(demoInventoryJson) as Map;
    for (final kind in ['items', 'reports']) {
      final byKey = {for (final row in fixture[kind] as List) row['key']: row};
      expect(bundle[kind], [
        for (final key
            in fixture[kind == 'items' ? 'seedItems' : 'seedReports'] as List)
          byKey[key],
      ]);
    }
  });
  withServerpod('Idempotent demo inventory', (builder, endpoints) {
    setUp(() => clearWorkerTestData(builder.build()));
    tearDown(() => clearWorkerTestData(builder.build()));
    test(
      'items and reports seed twice with unchanged ids, jobs and timestamps and produce proposals',
      () async {
        configureTestAuth();
        Providers.embedder = FakeEmbedder();
        Providers.normaliser = HintNormaliser();
        final s = builder.build();
        expect(await DemoInventoryService.items(s), 30);
        expect(await DemoInventoryService.reports(s), 7);
        final items = await FoundItem.db.find(s),
            reports = await LostReport.db.find(s),
            work = await WorkItem.db.find(s);
        expect(
          items.where((i) => i.restricted).length,
          greaterThanOrEqualTo(5),
        );
        expect(
          items
              .where((i) => i.refCode.startsWith('SEED'))
              .every(
                (i) => i.status == ItemStatus.captioning && i.photoPath == null,
              ),
          isTrue,
        );
        expect(await DemoInventoryService.items(s), 0);
        expect(await DemoInventoryService.reports(s), 0);
        expect(
          (await FoundItem.db.find(s)).map((i) => (i.id, i.updatedAt)),
          items.map((i) => (i.id, i.updatedAt)),
        );
        expect(
          (await LostReport.db.find(s)).map((r) => (r.id, r.updatedAt)),
          reports.map((r) => (r.id, r.updatedAt)),
        );
        expect(
          (await WorkItem.db.find(s)).map((j) => j.id),
          work.map((j) => j.id),
        );
        final worker = JobWorker(
          s.serverpod,
          handlers: [
            CaptionItemHandler(),
            MatchItemHandler(),
            MatchReportHandler(),
          ],
          renewLeases: false,
        );
        for (
          var n = 0;
          n < 100 &&
              await WorkItem.db.count(
                    s,
                    where: (t) => t.state.equals(WorkState.pending),
                  ) >
                  0;
          n++
        ) {
          await worker.tick(s);
        }
        expect(
          await WorkItem.db.count(
            s,
            where: (t) => t.state.equals(WorkState.failed),
          ),
          0,
        );
        for (final report in reports.where(
          (r) => r.refCode.startsWith('SEED'),
        )) {
          expect(
            await ItemMatch.db.count(
              s,
              where: (t) =>
                  t.reportId.equals(report.id!) &
                  t.state.equals(MatchState.pending),
            ),
            greaterThan(0),
          );
          expect(
            (await LostReport.db.findById(s, report.id!))!.status,
            ReportStatus.searching,
          );
        }
        expect(await FoundItem.db.count(s), 32);
        expect(await LostReport.db.count(s), 7);
        final returned = reports.singleWhere((r) => r.refCode == 'DEMORT');
        final claimed = items.singleWhere((i) => i.refCode == 'DEMORE');
        final expired = items.singleWhere((i) => i.refCode == 'DEMOEX');
        expect(returned.status, ReportStatus.returned);
        expect(returned.closedAt, isNotNull);
        expect(claimed.status, ItemStatus.claimed);
        expect(expired.status, ItemStatus.expired);
        expect(expired.holdUntil!.isBefore(DateTime.now()), isTrue);
        final release = (await ReleaseRecord.db.find(s)).single;
        expect(release.itemId, claimed.id);
        expect(release.reportId, returned.id);
        expect(release.venueId, claimed.venueId);
        expect(release.signaturePath, isNull);
        expect(release.idTypeSeen, 'none');
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) =>
                t.entityId.equals(returned.id!) & t.action.equals('returned'),
          ),
          1,
        );
        expect(
          await AuditEvent.db.count(
            s,
            where: (t) =>
                t.entityId.equals(expired.id!) & t.action.equals('expired'),
          ),
          1,
        );
        final terminalMatch = (await ItemMatch.db.find(
          s,
          where: (t) => t.reportId.equals(returned.id!),
        )).single;
        expect(terminalMatch.itemId, claimed.id);
        expect(terminalMatch.state, MatchState.confirmed);
        expect(
          await ItemMatch.db.count(
            s,
            where: (t) => t.itemId.equals(expired.id!),
          ),
          0,
        );
        expect(await ReleaseRecord.db.count(s), 1);
      },
    );
    test('every demo inventory endpoint refuses the wrong secret', () async {
      await expectLater(
        endpoints.admin.seedDemoItems(builder, 'invalid'),
        throwsException,
      );
      await expectLater(
        endpoints.admin.seedDemoReports(builder, 'invalid'),
        throwsException,
      );
      expect(await FoundItem.db.count(builder.build()), 0);
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
