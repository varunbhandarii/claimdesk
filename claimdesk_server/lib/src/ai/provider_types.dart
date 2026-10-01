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

class ReportHints {
  const ReportHints({
    this.categoryHint,
    this.colourHints = const [],
    this.brandHint,
    this.zoneName,
    this.whereText,
  });
  final String? categoryHint, brandHint, zoneName, whereText;
  final List<String> colourHints;
}

abstract class ReportNormaliser {
  String get id;
  Future<NormaliseResult> normalise(String rawText, ReportHints hints);
}

class NormaliseResult {
  const NormaliseResult({
    required this.attributes,
    required this.outcome,
    this.itemCount = 1,
    this.attempts = const [],
  });
  final ItemAttributes? attributes;
  final String outcome;
  final int itemCount;
  final List<CaptionAttempt> attempts;
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
