import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:claimdesk_server/src/ai/claude_normaliser.dart';
import 'package:claimdesk_server/src/ai/caption_validator.dart';
import 'package:claimdesk_server/src/ai/provider_types.dart';
import 'package:claimdesk_server/src/ai/report_normaliser.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

Map<String, dynamic> sample() => jsonDecode(
  File(
    'test/fixtures/providers/claude_normalise_umbrella.json',
  ).readAsStringSync(),
);

void main() {
  Future<void> noDelay(Duration _) async {}
  test(
    'selects text by type and sends only report and permitted hints',
    () async {
      final body = sample();
      (body['content'] as List).insert(0, {'type': 'thinking', 'thinking': ''});
      final c = ClaudeNormaliser(
        apiKey: 'fixture',
        delay: noDelay,
        client: MockClient((request) async {
          final sent = jsonDecode(request.body);
          expect(sent['max_tokens'], 1024);
          expect(sent['output_config']['effort'], 'low');
          expect(sent['messages'][0]['content'], hasLength(1));
          expect(request.body, isNot(contains('ownerOnlyDetails')));
          expect(request.body, isNot(contains('image/jpeg')));
          expect(
            sent['output_config']['format']['schema']['properties'],
            isNot(contains('image_quality')),
          );
          return http.Response(jsonEncode(body), 200);
        }),
      );
      final r = await c.normalise(
        'black umbrella wooden handle',
        const ReportHints(categoryHint: 'umbrella', colourHints: ['black']),
      );
      expect(r.attributes!.category, 'umbrella');
      expect(r.attributes!.source, 'report_llm');
      expect(r.attributes!.keywords.length, lessThanOrEqualTo(10));
      expect(r.attempts.single.outcome, 'ok');
    },
  );
  for (final failure in [
    'refusal',
    'max_tokens',
    'wrong_model',
    'transport',
    '429',
    '500',
    'invalid',
  ]) {
    test('$failure falls back with bounded retries and safe errors', () async {
      var calls = 0;
      final c = ChainNormaliser(
        ClaudeNormaliser(
          apiKey: 'fixture',
          delay: noDelay,
          client: MockClient((_) async {
            calls++;
            if (failure == 'transport') {
              throw TimeoutException('secret');
            }
            if (failure == '429' || failure == '500') {
              return http.Response('secret', int.parse(failure));
            }
            if (failure == 'invalid') {
              return http.Response('{}', 200);
            }
            final body = sample();
            if (failure == 'wrong_model') {
              body['model'] = 'unexpected';
            } else {
              body['stop_reason'] = failure;
            }
            return http.Response(jsonEncode(body), 200);
          }),
        ),
      );
      final r = await c.normalise(
        'a black brolly with wooden handle',
        const ReportHints(categoryHint: 'umbrella', colourHints: ['black']),
      );
      expect(calls, failure == 'refusal' ? 1 : 2);
      expect(r.outcome, 'fallback_hints');
      expect(r.attributes!.source, 'report_hints');
      expect(
        r.attempts.any((a) => a.errorMessage?.contains('secret') == true),
        isFalse,
      );
    });
  }
  test(
    'hint fallback handles missing hints and caps description and keywords',
    () async {
      final r = await HintNormaliser().normalise(
        List.filled(70, 'brolly wooden').join(' '),
        const ReportHints(),
      );
      expect(r.attributes!.category, 'other');
      expect(r.attributes!.colours, isEmpty);
      expect(r.attributes!.description.split(' '), hasLength(40));
      expect(r.attributes!.keywords, contains('wooden'));
    },
  );
  test(
    'restricted report removes brand marks keywords and description in both paths',
    () async {
      final body = sample();
      final text = (body['content'] as List).firstWhere(
        (b) => b['type'] == 'text',
      )['text'];
      final value = jsonDecode(text);
      value['items'][0]['category'] = 'wallet_or_purse';
      value['items'][0]['brand'] = 'NamedBrand';
      final a = CaptionValidator.parse(
        value,
        modelId: 'fixture',
        promptVersion: 'normalise_v1',
        report: true,
      );
      expect(a.brand, isNull);
      expect(a.marks, isEmpty);
      expect(a.keywords, isEmpty);
      final r = await HintNormaliser().normalise(
        'wallet containing personal papers',
        const ReportHints(
          categoryHint: 'wallet_or_purse',
          brandHint: 'NamedBrand',
        ),
      );
      expect(r.attributes!.description, 'wallet or purse');
      expect(r.attributes!.keywords, isEmpty);
    },
  );
  test(
    'rejects excess keywords, control characters and invalid categories',
    () {
      final body = sample();
      final text = (body['content'] as List).firstWhere(
        (b) => b['type'] == 'text',
      )['text'];
      for (final defect in ['keywords', 'control', 'category']) {
        final value = jsonDecode(text);
        if (defect == 'keywords') {
          value['keywords'] = List.filled(11, 'wooden');
        }
        if (defect == 'control') {
          value['items'][0]['description'] = 'wooden\u0001 handle';
        }
        if (defect == 'category') {
          value['items'][0]['category'] = 'invalid';
        }
        expect(
          () => CaptionValidator.parse(
            value,
            modelId: 'fixture',
            promptVersion: 'normalise_v1',
            report: true,
          ),
          throwsFormatException,
        );
      }
    },
  );
}
