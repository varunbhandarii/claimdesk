import '../generated/protocol.dart';
import '../policy/taxonomy.dart';
import 'prompts/normalise_v1.dart';
import 'provider_types.dart';
import 'text_template.dart';

class HintNormaliser implements ReportNormaliser {
  @override
  String get id => 'report_hints';
  @override
  Future<NormaliseResult> normalise(String rawText, ReportHints hints) async {
    final text = Taxonomy.canonicalize(
      rawText,
    ).replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ');
    final category = Taxonomy.groups.containsKey(hints.categoryHint)
        ? hints.categoryHint!
        : 'other';
    final attributes = protectAttributes(
      ItemAttributes(
        category: category,
        colours: hints.colourHints
            .where(Taxonomy.colours.contains)
            .toSet()
            .take(3)
            .toList(),
        brand: hints.brandHint,
        marks: [],
        description: text.trim().split(RegExp(r'\s+')).take(40).join(' '),
        containsPersonalData: Taxonomy.isRestricted(category),
        personalDataKinds: [],
        keywords: RegExp(r'[a-z]+')
            .allMatches(text.toLowerCase())
            .map((m) => m.group(0)!)
            .where((w) => w.length > 3 && !reportStopWords.contains(w))
            .toSet()
            .take(10)
            .toList(),
        source: id,
        modelId: 'hints',
        promptVersion: normalisePromptVersion,
      ),
    );
    return NormaliseResult(
      attributes: attributes,
      outcome: 'fallback_hints',
      attempts: [
        CaptionAttempt(
          provider: id,
          outcome: 'fallback_hints',
          modelId: 'hints',
          latencyMs: 0,
        ),
      ],
    );
  }
}

class ChainNormaliser implements ReportNormaliser {
  ChainNormaliser(this.primary, {ReportNormaliser? fallback})
    : fallback = fallback ?? HintNormaliser();
  final ReportNormaliser primary, fallback;
  @override
  String get id => primary.id;
  @override
  Future<NormaliseResult> normalise(String rawText, ReportHints hints) async {
    NormaliseResult result;
    try {
      result = await primary.normalise(rawText, hints);
    } catch (_) {
      result = NormaliseResult(
        attributes: null,
        outcome: 'transport_error',
        attempts: [
          CaptionAttempt(
            provider: primary.id,
            outcome: 'transport_error',
            modelId: primary.id,
            latencyMs: 0,
          ),
        ],
      );
    }
    if (result.attributes != null) return result;
    final replacement = await fallback.normalise(rawText, hints);
    return NormaliseResult(
      attributes: replacement.attributes,
      outcome: replacement.outcome,
      itemCount: replacement.itemCount,
      attempts: [...result.attempts, ...replacement.attempts],
    );
  }
}

const reportStopWords = {
  'a',
  'an',
  'the',
  'and',
  'or',
  'but',
  'if',
  'then',
  'this',
  'that',
  'these',
  'those',
  'i',
  'me',
  'my',
  'mine',
  'we',
  'our',
  'you',
  'your',
  'it',
  'its',
  'he',
  'she',
  'they',
  'their',
  'is',
  'are',
  'was',
  'were',
  'be',
  'been',
  'have',
  'has',
  'had',
  'do',
  'does',
  'did',
  'can',
  'could',
  'would',
  'should',
  'will',
  'with',
  'without',
  'of',
  'to',
  'in',
  'on',
  'at',
  'by',
  'for',
  'from',
  'as',
  'about',
  'near',
  'lost',
  'please',
  'some',
  'very',
  'just',
};
