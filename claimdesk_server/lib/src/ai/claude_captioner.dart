import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'caption_validator.dart';
import 'prompts/caption_v1.dart';
import 'provider_types.dart';

class ClaudeCaptioner implements ItemCaptioner {
  ClaudeCaptioner({
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
  @override
  String get id => 'claude';

  @override
  Future<CaptionResult> describe(
    Uint8List jpeg, {
    required String promptVersion,
    CaptionHints? hints,
  }) async {
    if (promptVersion != captionPromptVersion) {
      throw ArgumentError('Unknown caption prompt');
    }
    final attempts = <CaptionAttempt>[];
    var maxTokens = 2048;
    for (var attempt = 0; attempt < 2; attempt++) {
      final timer = Stopwatch()..start();
      var outcome = 'transport_error';
      String? error;
      String returnedModel = model;
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
                'system': captionV1,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Encode(jpeg),
                        },
                      },
                      {
                        'type': 'text',
                        'text':
                            'Describe the found item in this photo using the schema.',
                      },
                    ],
                  },
                ],
                'output_config': {
                  'format': {'type': 'json_schema', 'schema': captionSchema()},
                },
              }),
            )
            .timeout(timeout);
        if (response.statusCode != 200) {
          error = 'Vision HTTP ${response.statusCode}';
          retry = response.statusCode == 429 || response.statusCode >= 500;
        } else {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          returnedModel = body['model'] is String ? body['model'] : '';
          input = (body['usage']?['input_tokens'] as num?)?.toInt();
          output = (body['usage']?['output_tokens'] as num?)?.toInt();
          if (returnedModel != model) {
            outcome = 'invalid_json';
            error = 'Unexpected vision model';
            retry = true;
          } else if (body['stop_reason'] == 'refusal') {
            outcome = 'refused';
            error = 'Vision provider refused the image';
          } else if (body['stop_reason'] == 'max_tokens') {
            outcome = 'invalid_json';
            error = 'Vision output truncated';
            maxTokens = 4096;
            retry = true;
          } else if (body['stop_reason'] != 'end_turn') {
            outcome = 'invalid_json';
            error = 'Unexpected vision stop reason';
            retry = true;
          } else {
            final blocks = (body['content'] as List).whereType<Map>().where(
              (b) => b['type'] == 'text',
            );
            final text = blocks.map((b) => b['text'] as String).join();
            final attrs = CaptionValidator.parse(
              jsonDecode(text),
              modelId: returnedModel,
              promptVersion: promptVersion,
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
            return CaptionResult(
              attributes: attrs,
              outcome: 'ok',
              modelId: returnedModel,
              inputTokens: input,
              outputTokens: output,
              attempts: attempts,
            );
          }
        }
      } on TimeoutException {
        error = 'Vision request timed out';
        retry = true;
      } on http.ClientException {
        error = 'Vision transport unavailable';
        retry = true;
      } catch (_) {
        outcome = 'invalid_json';
        error = 'Invalid vision response';
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
        return CaptionResult(
          outcome: outcome,
          modelId: returnedModel,
          inputTokens: input,
          outputTokens: output,
          errorMessage: error,
          attempts: attempts,
        );
      }
      await delay(Duration(milliseconds: 2000 + Random().nextInt(3001)));
    }
    throw StateError('Unreachable caption retry state');
  }
}
