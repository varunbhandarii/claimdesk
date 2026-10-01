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
    test(
      'items and reports seed twice with unchanged ids, jobs and timestamps and produce proposals',
      () async {
        configureTestAuth();
        Providers.embedder = FakeEmbedder();
        Providers.normaliser = HintNormaliser();
        final s = builder.build();
        expect(await DemoInventoryService.items(s), 30);
        expect(await DemoInventoryService.reports(s), 6);
        final items = await FoundItem.db.find(s),
            reports = await LostReport.db.find(s),
            work = await WorkItem.db.find(s);
        expect(
          items.where((i) => i.restricted).length,
          greaterThanOrEqualTo(5),
        );
        expect(
          items.every(
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
        for (final report in reports) {
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
        expect(await FoundItem.db.count(s), 30);
        expect(await LostReport.db.count(s), 6);
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
  });
}
