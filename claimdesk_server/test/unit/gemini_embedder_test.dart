import 'dart:convert';
import 'dart:io';
import 'package:claimdesk_server/src/ai/gemini_embedder.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'document, query and batch calls use the right prefixes and normalize vectors',
    () async {
      final texts = <String>[];
      final fixture = jsonDecode(
        File(
          'test/fixtures/providers/gemini_embed_umbrella.json',
        ).readAsStringSync(),
      );
      final e = GeminiEmbedder(
        apiKey: 'test',
        client: MockClient((request) async {
          final body = jsonDecode(request.body);
          if (body['requests'] != null) {
            expect(body['requests'][0]['outputDimensionality'], 1536);
            return http.Response(
              jsonEncode({
                'embeddings': [fixture['embedding']],
              }),
              200,
            );
          }
          texts.add(body['content']['parts'][0]['text']);
          expect(body.containsKey('taskType'), isFalse);
          return http.Response(jsonEncode(fixture), 200);
        }),
      );
      final v = await e.embedDocument('umbrella');
      await e.embedQuery('brolly');
      await e.embedBatch(['umbrella']);
      expect(texts, [
        'title: none | text: umbrella',
        'task: search result | query: brolly',
      ]);
      expect(v, hasLength(1536));
      expect(v.fold<double>(0, (s, x) => s + x * x), closeTo(1, 1e-10));
      expect(e.modelId, 'gemini-embedding-2/1536');
    },
  );
  test('rejects a wrong-size vector', () async {
    final e = GeminiEmbedder(
      apiKey: 'test',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'embedding': {'values': List.filled(1535, 1)},
          }),
          200,
        ),
      ),
    );
    await expectLater(e.embedDocument('x'), throwsFormatException);
  });
  test('one rate-limit retry succeeds and batch size must match', () async {
    var calls = 0;
    final e = GeminiEmbedder(
      apiKey: 'test',
      delay: (_) async {},
      client: MockClient((_) async {
        calls++;
        return calls == 1
            ? http.Response('', 429)
            : http.Response(
                jsonEncode({
                  'embedding': {'values': List.filled(1536, 1)},
                }),
                200,
              );
      }),
    );
    expect(await e.embedQuery('x'), hasLength(1536));
    expect(calls, 2);
  });
}
