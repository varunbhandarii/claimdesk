@Tags(['eval'])
library;

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:claimdesk_server/src/ai/claude_normaliser.dart';
import 'package:claimdesk_server/src/ai/gemini_embedder.dart';
import 'package:test/test.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import 'eval_harness.dart';
import 'metrics.dart';

void main() {
  withServerpod('Live matching evaluation', (builder, _) {
    test(
      'real providers meet retrieval and false positive targets',
      () async {
        final anthropic = Platform.environment['ANTHROPIC_API_KEY'],
            gemini = Platform.environment['GEMINI_API_KEY'];
        if (anthropic == null || gemini == null) {
          throw StateError(
            'Set provider keys in process environment before this opt-in evaluation',
          );
        }
        final model =
            Platform.environment['CLAIMDESK_NORMALISE_MODEL'] ??
            'claude-opus-5-5';
        final harness = EvalHarness(
          embedder: GeminiEmbedder(apiKey: gemini),
          normaliser: ClaudeNormaliser(apiKey: anthropic, model: model),
          cache: Directory('test/fixtures/matching/cache'),
        );
        final s = builder.build();
        await harness.seed(s);
        final result = await harness.run(s), m = metrics(result.rankings);
        print(
          'Models: $model / ${harness.embedder.modelId}\n${metricsTable(m)}\n${result.cosineDistribution}',
        );
        for (final r in result.rankings) {
          print(
            '${r.reportKey}: expected=${r.expectedItem} ranked=${r.rows.map((row) => '${row.itemKey}:${row.result.label}:${row.result.score.toStringAsFixed(3)}').join(', ')}',
          );
        }
        expect(
          result.differences,
          isEmpty,
          reason: result.differences.join('\n'),
        );
        expect(m.recall3, greaterThanOrEqualTo(.90));
        expect(m.mrr, greaterThanOrEqualTo(.80));
        expect(m.strongFpr, lessThanOrEqualTo(.10));
        final umbrella = result.rankings.singleWhere(
          (r) => r.reportKey == 'report_01',
        );
        expect(umbrella.rows.first.itemKey, 'wood_umbrella');
        expect(umbrella.rows.first.result.label, 'strong');
        expect(
          umbrella.rows
              .singleWhere((r) => r.itemKey == 'plastic_umbrella')
              .result
              .label,
          'possible',
        );
      },
      timeout: const Timeout(Duration(minutes: 20)),
      skip:
          Platform.environment['RUN_MATCHING_EVAL'] != 'true' ||
              Platform.environment['ANTHROPIC_API_KEY'] == null ||
              Platform.environment['GEMINI_API_KEY'] == null
          ? 'Set RUN_MATCHING_EVAL=true and both provider keys for this manual run'
          : false,
    );
  });
}
