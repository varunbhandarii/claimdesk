import 'dart:typed_data';
import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import 'provider_types.dart';
import 'text_template.dart';

class TemplateCaptioner implements ItemCaptioner {
  @override
  String get id => 'template';
  @override
  Future<CaptionResult> describe(
    Uint8List jpeg, {
    required String promptVersion,
    CaptionHints? hints,
  }) async {
    final category = Taxonomy.groups.containsKey(hints?.category)
        ? hints!.category!
        : 'other';
    final colours = (hints?.colours ?? [])
        .where(Taxonomy.colours.contains)
        .toSet()
        .take(3)
        .toList();
    final attrs = protectAttributes(
      ItemAttributes(
        category: category,
        colours: colours,
        brand: hints?.brand,
        marks: [],
        description: hints?.notes?.trim().isNotEmpty == true
            ? hints!.notes!.trim()
            : '${colours.join(' ')} ${Taxonomy.label(category)} (staff description)'
                  .trim(),
        containsPersonalData:
            Taxonomy.isRestricted(category) ||
            (hints?.containsPersonalData ?? false),
        personalDataKinds: hints?.personalDataKinds ?? [],
        keywords: [],
        source: 'staff_typed',
        modelId: 'template',
        promptVersion: promptVersion,
      ),
    );
    return CaptionResult(
      attributes: attrs,
      outcome: 'fallback_template',
      modelId: 'template',
      attempts: [
        const CaptionAttempt(
          provider: 'template',
          outcome: 'fallback_template',
          modelId: 'template',
          latencyMs: 0,
        ),
      ],
    );
  }
}

class ChainCaptioner implements ItemCaptioner {
  ChainCaptioner(this.primary, {ItemCaptioner? fallback})
    : fallback = fallback ?? TemplateCaptioner();
  final ItemCaptioner primary, fallback;
  @override
  String get id => primary.id;
  @override
  Future<CaptionResult> describe(
    Uint8List jpeg, {
    required String promptVersion,
    CaptionHints? hints,
  }) async {
    CaptionResult result;
    try {
      result = await primary.describe(
        jpeg,
        promptVersion: promptVersion,
        hints: hints,
      );
    } catch (_) {
      result = CaptionResult(
        outcome: 'transport_error',
        attempts: [
          CaptionAttempt(
            provider: primary.id,
            outcome: 'transport_error',
            modelId: primary.id,
            latencyMs: 0,
            errorMessage: 'Caption provider unavailable',
          ),
        ],
      );
    }
    if (result.attributes != null) return result;
    final replacement = await fallback.describe(
      jpeg,
      promptVersion: promptVersion,
      hints: hints,
    );
    return CaptionResult(
      attributes: replacement.attributes,
      outcome: replacement.outcome,
      modelId: replacement.modelId,
      attempts: [...result.attempts, ...replacement.attempts],
    );
  }
}
