@Tags(['integration'])
library;

// ignore_for_file: avoid_print

import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/ai/report_normaliser.dart';
import 'package:test/test.dart';
import '../eval/eval_harness.dart';
import '../eval/metrics.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Synthetic matching evaluation', (builder, _) {
    test(
      'fake providers meet retrieval floors and SQL agrees with the reference for every report',
      () async {
        final harness = EvalHarness(
          embedder: FakeEmbedder(),
          normaliser: HintNormaliser(),
        );
        final s = builder.build();
        await harness.seed(s);
        final result = await harness.run(s), m = metrics(result.rankings);
        print('${metricsTable(m)}\n${result.cosineDistribution}');
        expect(harness.items, hasLength(40));
        expect(harness.reports, hasLength(30));
        expect(harness.expected.values.whereType<String>(), hasLength(22));
        expect(
          result.differences,
          isEmpty,
          reason: result.differences.join('\n'),
        );
        expect(m.recall3, greaterThanOrEqualTo(.75));
        expect(m.strongFpr, lessThanOrEqualTo(.25));
      },
    );
  });
}
