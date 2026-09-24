import 'dart:typed_data';
import '../generated/protocol.dart';

class CaptionHints {
  const CaptionHints({
    this.category,
    this.colours = const [],
    this.brand,
    this.notes,
    this.fixtureName,
    this.containsPersonalData = false,
    this.personalDataKinds = const [],
  });
  final String? category, brand, notes, fixtureName;
  final List<String> colours;
  final bool containsPersonalData;
  final List<String> personalDataKinds;
  factory CaptionHints.fromAttributes(ItemAttributes? a) => CaptionHints(
    category: a?.category,
    colours: a?.colours ?? [],
    brand: a?.brand,
    notes: a?.description,
    containsPersonalData: a?.containsPersonalData ?? false,
    personalDataKinds: a?.personalDataKinds ?? [],
  );
}

abstract class ItemCaptioner {
  String get id;
  Future<CaptionResult> describe(
    Uint8List jpeg, {
    required String promptVersion,
    CaptionHints? hints,
  });
}

abstract class TextEmbedder {
  String get modelId;
  int get dimensions;
  Future<List<double>> embedDocument(String text);
  Future<List<double>> embedQuery(String text);
}

class CaptionAttempt {
  const CaptionAttempt({
    required this.provider,
    required this.outcome,
    required this.modelId,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
    this.errorMessage,
  });
  final String provider, outcome, modelId;
  final int latencyMs;
  final int? inputTokens, outputTokens;
  final String? errorMessage;
}

class CaptionResult {
  const CaptionResult({
    this.attributes,
    required this.outcome,
    this.modelId,
    this.errorMessage,
    this.inputTokens,
    this.outputTokens,
    this.attempts = const [],
  });
  final ItemAttributes? attributes;
  final String outcome;
  final int? inputTokens, outputTokens;
  final String? modelId, errorMessage;
  final List<CaptionAttempt> attempts;
}
