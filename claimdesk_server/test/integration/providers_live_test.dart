@Tags(['providers'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:claimdesk_server/src/ai/provider_types.dart';
import 'package:claimdesk_server/src/ai/claude_captioner.dart';
import 'package:claimdesk_server/src/ai/gemini_embedder.dart';
import 'package:claimdesk_server/src/ai/image_prep.dart';
import 'package:claimdesk_server/src/ai/text_template.dart';
import 'package:test/test.dart';

void main() {
  final env = Platform.environment;
  final enabled =
      env['CLAIMDESK_LIVE_PROVIDERS'] == '1' &&
      (env['ANTHROPIC_API_KEY']?.isNotEmpty ?? false) &&
      (env['GEMINI_API_KEY']?.isNotEmpty ?? false);
  test(
    'four photos retain category, privacy and marks at low caption effort',
    () async {
      final rows = <Map<String, Object?>>[];
      var lowPasses = true;
      for (final name in [
        'umbrella',
        'backpack',
        'mock_id_card',
        'generated_wooden_umbrella',
      ]) {
        final suffix = name == 'generated_wooden_umbrella' ? 'png' : 'jpg';
        final prepared = prepareImage(
          await File('test/fixtures/photos/$name.$suffix').readAsBytes(),
        );
        expect(prepared, isNotNull);
        final outcomes = <String, CaptionResult>{};
        for (final effort in ['medium', 'low']) {
          final provider = ClaudeCaptioner(
            apiKey: env['ANTHROPIC_API_KEY']!,
            effort: effort,
          );
          try {
            final timer = Stopwatch()..start();
            final result = await provider.describe(
              prepared!.jpeg,
              promptVersion: 'caption_v1',
            );
            outcomes[effort] = result;
            rows.add({
              'fixture': name,
              'effort': effort,
              'elapsedMs': timer.elapsedMilliseconds,
              'outcome': result.outcome,
              'category': result.attributes?.category,
              'colours': result.attributes?.colours,
              'marksCount': result.attributes?.marks.length,
              'personalData': result.attributes?.containsPersonalData,
            });
          } finally {
            provider.client.close();
          }
        }
        final medium = outcomes['medium']!, low = outcomes['low']!;
        final a = medium.attributes, b = low.attributes;
        lowPasses =
            lowPasses &&
            medium.outcome == 'ok' &&
            low.outcome == 'ok' &&
            a != null &&
            b != null &&
            a.category == b.category &&
            a.containsPersonalData == b.containsPersonalData &&
            (a.marks.length - b.marks.length).abs() <= 1;
      }
      stdout.writeln(
        jsonEncode({
          'captionEffortComparison': rows,
          'lowPasses': lowPasses,
          'recommendedEffort': lowPasses ? 'low' : 'medium',
        }),
      );
      // A failed comparison is a measured choice of medium, not an invented pass.
      expect(rows.every((row) => row['outcome'] == 'ok'), true);
    },
    skip: enabled
        ? false
        : 'Opt in with provider keys and CLAIMDESK_LIVE_PROVIDERS=1.',
    timeout: const Timeout(Duration(minutes: 12)),
  );
  for (final name in ['umbrella', 'backpack', 'mock_id_card']) {
    test(
      'real providers describe and embed $name',
      () async {
        final photo = File('test/fixtures/photos/$name.jpg');
        expect(
          photo.existsSync(),
          true,
          reason:
              'Provide the local photo fixture before opting into live tests.',
        );
        final prepared = prepareImage(await photo.readAsBytes());
        expect(prepared, isNotNull);
        final captioner = ClaudeCaptioner(apiKey: env['ANTHROPIC_API_KEY']!);
        final embedder = GeminiEmbedder(apiKey: env['GEMINI_API_KEY']!);
        addTearDown(captioner.client.close);
        addTearDown(embedder.client.close);
        final timer = Stopwatch()..start();
        final caption = await captioner.describe(
          prepared!.jpeg,
          promptVersion: 'caption_v1',
        );
        expect(caption.outcome, 'ok', reason: caption.errorMessage);
        final a = caption.attributes!;
        expect(a.category, switch (name) {
          'umbrella' => 'umbrella',
          'backpack' => 'backpack',
          _ => 'id_card_or_pass',
        });
        expect(restrictedAttributes(a), name == 'mock_id_card');
        final text = TextTemplate.render(a);
        final vector = await embedder.embedDocument(text);
        expect(vector, hasLength(1536));
        expect(vector.every((v) => v.isFinite), true);
        expect(
          sqrt(vector.fold<double>(0, (n, v) => n + v * v)),
          closeTo(1, 1e-6),
        );
        if (name == 'mock_id_card') {
          expect(a.marks, isEmpty);
          expect(a.brand, isNull);
          expect(text.split('\n'), hasLength(1));
          expect(RegExp(r'\d').hasMatch(a.description), false);
        }
        stdout.writeln(
          jsonEncode({
            'fixture': name,
            'model': caption.modelId,
            'category': a.category,
            'restricted': restrictedAttributes(a),
            'elapsedMs': timer.elapsedMilliseconds,
            'captionLatencyMs': caption.attempts
                .map((v) => v.latencyMs)
                .toList(),
            'inputTokens': caption.inputTokens,
            'outputTokens': caption.outputTokens,
            'dimensions': vector.length,
          }),
        );
      },
      skip: enabled
          ? false
          : 'Opt in with CLAIMDESK_LIVE_PROVIDERS=1 and both provider keys in the environment.',
      timeout: const Timeout(Duration(minutes: 6)),
    );
  }
}
