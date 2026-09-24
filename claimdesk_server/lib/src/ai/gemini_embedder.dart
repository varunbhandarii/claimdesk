import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'provider_types.dart';

class GeminiEmbedder implements TextEmbedder {
  GeminiEmbedder({
    required this.apiKey,
    this.model = 'gemini-embedding-2',
    http.Client? client,
    Future<void> Function(Duration)? delay,
    this.timeout = const Duration(seconds: 60),
  }) : client = client ?? http.Client(),
       delay = delay ?? Future<void>.delayed;
  final String apiKey, model;
  final http.Client client;
  final Duration timeout;
  final Future<void> Function(Duration) delay;
  @override
  String get modelId => '$model/1536';
  @override
  int get dimensions => 1536;
  Map<String, Object> _request(String text) => {
    'model': 'models/$model',
    'content': {
      'parts': [
        {'text': text},
      ],
    },
    'outputDimensionality': dimensions,
  };
  List<double> _vector(Object? source) {
    if (source is! List ||
        source.length != dimensions ||
        source.any((v) => v is! num || !v.isFinite)) {
      throw const FormatException('Invalid embedding dimensions or values');
    }
    final values = source.map((v) => (v as num).toDouble()).toList();
    final norm = sqrt(values.fold<double>(0, (s, v) => s + v * v));
    if (!norm.isFinite || norm == 0) {
      throw const FormatException('Invalid embedding norm');
    }
    return values.map((v) => v / norm).toList();
  }

  Future<Map<String, dynamic>> _call(String method, Object body) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await client
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$model:$method',
              ),
              headers: {
                'x-goog-api-key': apiKey,
                'content-type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(timeout);
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        if (attempt == 0 &&
            (response.statusCode == 429 || response.statusCode >= 500)) {
          await delay(const Duration(seconds: 2));
          continue;
        }
        throw StateError('Embedding HTTP ${response.statusCode}');
      } on TimeoutException {
        if (attempt == 1) throw StateError('Embedding request timed out');
      } on http.ClientException {
        if (attempt == 1) throw StateError('Embedding transport unavailable');
      }
    }
    throw StateError('Embedding unavailable');
  }

  @override
  Future<List<double>> embedDocument(String text) async => _vector(
    (await _call(
      'embedContent',
      _request('title: none | text: $text'),
    ))['embedding']?['values'],
  );
  @override
  Future<List<double>> embedQuery(String text) async => _vector(
    (await _call(
      'embedContent',
      _request('task: search result | query: $text'),
    ))['embedding']?['values'],
  );
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    if (texts.isEmpty) return [];
    final body = await _call('batchEmbedContents', {
      'requests': texts.map((t) => _request('title: none | text: $t')).toList(),
    });
    final embeddings = body['embeddings'];
    if (embeddings is! List || embeddings.length != texts.length) {
      throw const FormatException('Invalid embedding batch');
    }
    return embeddings.map((e) => _vector(e['values'])).toList();
  }
}
