import 'dart:async';
import 'dart:convert';
import 'claude_model_ids.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'caption_validator.dart';
import 'prompts/normalise_v1.dart';
import 'provider_types.dart';

class ClaudeNormaliser implements ReportNormaliser {
  ClaudeNormaliser({
    required this.apiKey,
    this.model = 'claude-opus-5-5',
    http.Client? client,
    Future<void> Function(Duration)? delay,
    this.timeout = const Duration(seconds: 120),
  }) : client = client ?? http.Client(),
       delay = delay ?? Future<void>.delayed;
  final String apiKey, model;
  final http.Client client;
  final Duration timeout;
  final Future<void> Function(Duration) delay;
  String? get effort =>
      model.startsWith('claude-opus-') || model.startsWith('claude-sonnet-')
      ? 'low'
      : null;
  @override
  String get id => 'claude_normaliser';
  @override
  Future<NormaliseResult> normalise(String rawText, ReportHints hints) async {
    final attempts = <CaptionAttempt>[];
    var maxTokens = 1024;
    for (var attempt = 0; attempt < 2; attempt++) {
      final timer = Stopwatch()..start();
      var outcome = 'transport_error';
      String? error;
      var returnedModel = model;
      int? input, output;
      var retry = false;
      try {
        final response = await client
            .post(
              Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'x-api-key': apiKey,
                'anthropic-version': '2023-06-01',
                'content-type': 'application/json',
              },
              body: jsonEncode({
                'model': model,
                'max_tokens': maxTokens,
                'system': normaliseV1,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'text',
                        'text':
                            'Report data:\n```json\n${jsonEncode({'report': rawText, 'categoryHint': hints.categoryHint, 'colours': hints.colourHints, 'brandHint': hints.brandHint, 'zone': hints.zoneName, 'where': hints.whereText})}\n```',
                      },
                    ],
                  },
                ],
                'output_config': {
                  if (effort != null) 'effort': effort,
                  'format': {
                    'type': 'json_schema',
                    'schema': normaliseSchema(),
                  },
                },
              }),
            )
            .timeout(timeout);
        if (response.statusCode != 200) {
          error = 'Normalisation HTTP ${response.statusCode}';
          retry = response.statusCode == 429 || response.statusCode >= 500;
        } else {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          returnedModel = body['model'] is String ? body['model'] : '';
          input = (body['usage']?['input_tokens'] as num?)?.toInt();
          output = (body['usage']?['output_tokens'] as num?)?.toInt();
          if (!matchesClaudeModel(model, returnedModel)) {
            outcome = 'invalid_json';
            error = 'Unexpected normalisation model';
            retry = true;
          } else if (body['stop_reason'] == 'refusal') {
            outcome = 'refused';
            error = 'Normalisation provider refused the report';
          } else if (body['stop_reason'] == 'max_tokens') {
            outcome = 'invalid_json';
            error = 'Normalisation output truncated';
            maxTokens = 2048;
            retry = true;
          } else if (body['stop_reason'] != 'end_turn') {
            outcome = 'invalid_json';
            error = 'Unexpected normalisation stop reason';
            retry = true;
          } else {
            final text = (body['content'] as List)
                .whereType<Map>()
                .where((b) => b['type'] == 'text')
                .map((b) => b['text'] as String)
                .join();
            final value = jsonDecode(text);
            final attributes = CaptionValidator.parse(
              value,
              modelId: returnedModel,
              promptVersion: normalisePromptVersion,
              report: true,
            );
            attempts.add(
              CaptionAttempt(
                provider: id,
                outcome: 'ok',
                modelId: returnedModel,
                latencyMs: timer.elapsedMilliseconds,
                inputTokens: input,
                outputTokens: output,
              ),
            );
            return NormaliseResult(
              attributes: attributes,
              outcome: 'ok',
              itemCount: (value['items'] as List).length,
              attempts: attempts,
            );
          }
        }
      } on TimeoutException {
        error = 'Normalisation request timed out';
        retry = true;
      } on http.ClientException {
        error = 'Normalisation transport unavailable';
        retry = true;
      } catch (_) {
        outcome = 'invalid_json';
        error = 'Invalid normalisation response';
        retry = true;
      }
      attempts.add(
        CaptionAttempt(
          provider: id,
          outcome: outcome,
          modelId: returnedModel,
          latencyMs: timer.elapsedMilliseconds,
          inputTokens: input,
          outputTokens: output,
          errorMessage: error,
        ),
      );
      if (attempt == 1 || !retry) {
        return NormaliseResult(
          attributes: null,
          outcome: outcome,
          attempts: attempts,
        );
      }
      await delay(Duration(milliseconds: 2000 + Random().nextInt(3001)));
    }
    throw StateError('Unreachable normalisation retry state');
  }
}
