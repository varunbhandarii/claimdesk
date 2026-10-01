import 'taxonomy.dart';

class VerificationQuestions {
  static const location =
      'Where exactly were you when you last had it, and roughly what time?';
  static const fallback =
      'Describe one detail that is not visible from the outside or that only the owner would know.';
  static List<String> forCategory(String category) {
    final question = switch (category) {
      'umbrella' =>
        'What is the handle made of, and is anything written or attached on it?',
      'backpack' ||
      'handbag' ||
      'tote_or_shopping_bag' ||
      'suitcase_or_luggage' =>
        'What is inside the main compartment, and are there tags, keyrings or badges on the zips?',
      'wallet_or_purse' || 'bank_card' || 'cash' =>
        'Name one card, note or item inside without giving any numbers.',
      'keys' => 'How many keys are on it, and what else is on the ring?',
      'phone' || 'tablet_or_laptop' || 'smartwatch_or_watch' || 'camera' =>
        'What is on the lock screen or case, and is there a sticker, crack or engraving?',
      'earbuds_or_headphones' || 'charger_or_cable' =>
        'Describe the case or cable: colour, any marks, and what was with it.',
      'id_card_or_pass' || 'book_or_document' =>
        'Whose name is on it, and what else was with it? (Answer with your name only; no numbers.)',
      'jacket_or_coat' ||
      'hat_or_cap' ||
      'scarf_or_gloves' ||
      'clothing_other' ||
      'footwear' =>
        'What size is it, and what was in the pockets or written on the label?',
      'water_bottle_or_flask' =>
        'What is on the bottle: stickers, dents, scratches, a name?',
      _ => null,
    };
    if (question != null) return [question, location];
    // Group hints from older clients use the same question as their fine category.
    final representative = Taxonomy.groups.entries
        .where((e) => e.value == category)
        .firstOrNull;
    return representative == null
        ? [fallback, location]
        : forCategory(representative.key);
  }

  static Map<String, String> validate(List<String> answers) => {
    for (var i = 0; i < 2; i++)
      if (answers.length <= i ||
          answers[i].trim().length < 10 ||
          answers[i].trim().length > 300)
        'answer${i + 1}': 'Use 10 to 300 characters for this answer.',
  };
}
