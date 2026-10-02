import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:claimdesk_server/src/ai/claude_captioner.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'caption_examples.dart';

void main() {
  Future<void> noDelay(Duration _) async {}
  for (final effort in ['', 'low', 'medium', 'high']) {
    test('caption request preserves schema with effort "$effort"', () async {
      final captioner = ClaudeCaptioner(
        apiKey: 'test',
        effort: effort,
        client: MockClient((request) async {
          final sent = jsonDecode(request.body);
          expect(sent['output_config']['format']['type'], 'json_schema');
          expect(
            sent['output_config'].containsKey('effort'),
            effort.isNotEmpty,
          );
          if (effort.isNotEmpty) {
            expect(sent['output_config']['effort'], effort);
          }
          expect(sent.containsKey('thinking'), false);
          return http.Response(jsonEncode(claudeBody()), 200);
        }),
      );
      addTearDown(captioner.client.close);
      expect(
        (await captioner.describe(
          Uint8List(0),
          promptVersion: 'caption_v1',
        )).outcome,
        'ok',
      );
    });
  }
  test(
    'parses text after thinking and captures usage and requested model',
    () async {
      final c = ClaudeCaptioner(
        apiKey: 'test',
        delay: noDelay,
        client: MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(body['output_config']['format']['type'], 'json_schema');
          expect(body['messages'][0]['content'][0]['type'], 'image');
          return http.Response(jsonEncode(claudeBody()), 200);
        }),
      );
      final result = await c.describe(
        Uint8List(0),
        promptVersion: 'caption_v1',
      );
      expect(result.attributes!.category, 'umbrella');
      expect(result.modelId, 'claude-opus-5-5');
      expect(result.inputTokens, 500);
      expect(result.outputTokens, 100);
      expect(result.attempts, hasLength(1));
    },
  );
  test('refusal is reported without inventing attributes', () async {
    final c = ClaudeCaptioner(
      apiKey: 'test',
      delay: noDelay,
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode(claudeBody(stop: 'refusal')), 200),
      ),
    );
    final r = await c.describe(Uint8List(0), promptVersion: 'caption_v1');
    expect(r.outcome, 'refused');
    expect(r.attributes, isNull);
  });
  for (final failure in [
    'max_tokens',
    '429',
    '500',
    'invalid_json',
    'timeout',
    'wrong_model',
  ]) {
    test('$failure is retried once with a bounded request count', () async {
      var calls = 0;
      final c = ClaudeCaptioner(
        apiKey: 'test',
        delay: noDelay,
        client: MockClient((request) async {
          calls++;
          if (failure == 'max_tokens' && calls == 2) {
            expect(jsonDecode(request.body)['max_tokens'], 4096);
          }
          if (calls == 1) {
            if (failure == '429' || failure == '500') {
              return http.Response('withheld', int.parse(failure));
            }
            if (failure == 'timeout') throw TimeoutException('fixture');
            if (failure == 'invalid_json') return http.Response('{}', 200);
            return http.Response(
              jsonEncode(
                claudeBody(
                  stop: failure == 'max_tokens' ? 'max_tokens' : 'end_turn',
                  model: failure == 'wrong_model'
                      ? 'unexpected'
                      : 'claude-opus-5-5',
                ),
              ),
              200,
            );
          }
          return http.Response(jsonEncode(claudeBody()), 200);
        }),
      );
      final r = await c.describe(Uint8List(0), promptVersion: 'caption_v1');
      expect(calls, 2);
      expect(r.outcome, 'ok');
      expect(r.attempts, hasLength(2));
    });
  }
  test(
    'two server errors report transport_error with no response-body leak',
    () async {
      var calls = 0;
      final c = ClaudeCaptioner(
        apiKey: 'test',
        delay: noDelay,
        client: MockClient((_) async {
          calls++;
          return http.Response('secret response', 500);
        }),
      );
      final r = await c.describe(Uint8List(0), promptVersion: 'caption_v1');
      expect(calls, 2);
      expect(r.outcome, 'transport_error');
      expect(r.errorMessage, isNot(contains('secret')));
    },
  );
}
