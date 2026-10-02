@Tags(['eval'])
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:claimdesk_server/src/ai/claude_normaliser.dart';
import 'package:claimdesk_server/src/ai/gemini_embedder.dart';
import 'package:claimdesk_server/src/matching/match_weights.dart';
import 'package:test/test.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import 'eval_harness.dart';
import 'metrics.dart';

void main() {
  withServerpod('Live matching evaluation', (builder, _) {
    test(
      'real providers meet retrieval and false positive targets on every set',
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
        final weights = MatchWeights(
          semanticLow:
              double.tryParse(
                Platform.environment['EVAL_SEMANTIC_LOW'] ?? '',
              ) ??
              const MatchWeights().semanticLow,
          semanticHigh:
              double.tryParse(
                Platform.environment['EVAL_SEMANTIC_HIGH'] ?? '',
              ) ??
              const MatchWeights().semanticHigh,
        );
        final failures = <String>[];
        for (final set in ['text', 'photo', 'combined']) {
          final harness = EvalHarness(
            embedder: GeminiEmbedder(apiKey: gemini),
            normaliser: ClaudeNormaliser(apiKey: anthropic, model: model),
            cache: Directory('test/fixtures/matching/cache'),
            set: set,
            weights: weights,
          );
          final s = builder.build();
          await harness.seed(s);
          final result = await harness.run(s), m = metrics(result.rankings);
          final times = harness.normalisationMs.values.toList()..sort();
          int percentile(double p) => times[((times.length - 1) * p).round()];
          print(
            'Models: $model / ${harness.embedder.modelId}; set=$set; semantic=${weights.semanticLow}/${weights.semanticHigh}\n${metricsTable(m)}\nNormalisation p50=${percentile(.5)}ms p90=${percentile(.9)}ms\n${result.cosineDistribution}',
          );
          print(
            'EVAL_JSON ${jsonEncode({
              'model': model,
              'set': set,
              'semanticLow': weights.semanticLow,
              'semanticHigh': weights.semanticHigh,
              'recall1': m.recall1,
              'recall3': m.recall3,
              'mrr': m.mrr,
              'strongFpr': m.strongFpr,
              'strongPrecision': m.strongPrecision,
              'p50Ms': percentile(.5),
              'p90Ms': percentile(.9),
              'trueCosines': result.trueCosines,
              'falseCosines': result.falseCosines,
              'rankings': [
                for (final r in result.rankings) {
                    'report': r.reportKey,
                    'expected': r.expectedItem,
                    'rows': [
                      for (final row in r.rows) {
                          'item': row.itemKey,
                          'label': row.result.label,
                          'score': row.result.score,
                          'photo': row.result.candidate.item.attributes?.source == 'vision',
                          'keywords': row.result.explanation.matchedKeywords,
                        },
                    ],
                  },
              ],
            })}',
          );
          failures.addAll(result.differences);
          if (m.recall3 < .90 || m.mrr < .80 || m.strongFpr > .10) {
            failures.add('$set metrics missed live gates');
          }
          if (set != 'text') {
            final hero = result.rankings.singleWhere(
              (r) => r.reportKey == 'photo_report_01',
            );
            if (!hero.rows.any(
              (r) =>
                  r.itemKey == 'wood_umbrella' &&
                  r.result.candidate.item.attributes?.source == 'vision' &&
                  r.result.label == 'strong',
            )) {
              failures.add('$set photo-backed wooden umbrella is not strong');
            }
            final control = result.rankings.singleWhere(
              (r) => r.reportKey == 'photo_report_02',
            );
            if (control.rows
                .where((r) => r.itemKey == 'wood_umbrella')
                .any(
                  (r) =>
                      r.result.label == 'strong' ||
                      r.result.explanation.matchedKeywords.any(
                        (k) => k.contains('wood'),
                      ),
                )) {
              failures.add(
                '$set plastic control has a strong wooden umbrella or wooden chip',
              );
            }
          }
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      },
      timeout: const Timeout(Duration(minutes: 30)),
      skip:
          Platform.environment['RUN_MATCHING_EVAL'] != 'true' ||
              Platform.environment['ANTHROPIC_API_KEY'] == null ||
              Platform.environment['GEMINI_API_KEY'] == null
          ? 'Set RUN_MATCHING_EVAL=true and both provider keys for this manual run'
          : false,
    );
  });
}
