import 'dart:math';
import 'dart:typed_data';
import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import '../matching/english_lexemes.dart';
import 'provider_types.dart';
import 'text_template.dart';

class FakeCaptioner implements ItemCaptioner {
  FakeCaptioner({this.failures = 0, this.fixtureName, this.attributes});
  int failures;
  final String? fixtureName;
  final ItemAttributes? attributes;
  @override
  String get id => 'fake';
  @override
  Future<CaptionResult> describe(
    Uint8List jpeg, {
    required String promptVersion,
    CaptionHints? hints,
  }) async {
    final failed = failures-- > 0;
    final name = hints?.fixtureName ?? fixtureName;
    final category = switch (name) {
      'umbrella' => 'umbrella',
      'backpack' => 'backpack',
      'mock_id_card' => 'id_card_or_pass',
      _ => hints?.category ?? 'other',
    };
    final attrs = protectAttributes(
      attributes ??
          ItemAttributes(
            category: category,
            colours: category == 'id_card_or_pass' ? [] : ['black'],
            brand: null,
            marks: category == 'umbrella' ? ['wooden handle'] : [],
            description: category == 'umbrella'
                ? 'Black umbrella with a wooden handle'
                : Taxonomy.label(category),
            containsPersonalData: category == 'id_card_or_pass',
            personalDataKinds: category == 'id_card_or_pass'
                ? ['id_document']
                : [],
            keywords: [],
            source: 'fake',
            modelId: 'fake-caption',
            promptVersion: promptVersion,
          ),
    );
    final outcome = failed ? 'transport_error' : 'ok';
    return CaptionResult(
      attributes: failed ? null : attrs,
      outcome: outcome,
      modelId: 'fake-caption',
      inputTokens: 10,
      outputTokens: 10,
      attempts: [
        CaptionAttempt(
          provider: id,
          outcome: outcome,
          modelId: 'fake-caption',
          latencyMs: 0,
          inputTokens: 10,
          outputTokens: 10,
        ),
      ],
    );
  }
}

class FakeEmbedder implements TextEmbedder {
  FakeEmbedder({this.fail = false});
  bool fail;
  @override
  String get modelId => 'fake-token-hash/1536';
  @override
  int get dimensions => 1536;
  @override
  Future<List<double>> embedDocument(String text) async {
    if (fail) throw StateError('Embedding unavailable');
    final vector = List<double>.filled(dimensions, 0);
    final tokens = EnglishLexemes.tokens(Taxonomy.canonicalize(text));
    final features = [
      ...tokens,
      for (var i = 0; i + 1 < tokens.length; i++)
        '${tokens[i]} ${tokens[i + 1]}',
    ];
    for (final token in features) {
      var hash = 2166136261;
      for (final c in token.codeUnits) {
        hash = ((hash ^ c) * 16777619) & 0xffffffff;
      }
      vector[hash % dimensions] += hash & 0x80000000 == 0 ? 1 : -1;
    }
    var norm = sqrt(vector.fold<double>(0, (s, v) => s + v * v));
    if (norm == 0) {
      vector[0] = 1;
      norm = 1;
    }
    return vector.map((v) => v / norm).toList();
  }

  @override
  Future<List<double>> embedQuery(String text) => embedDocument(text);
}
