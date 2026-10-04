import '../generated/protocol.dart';

/// Short, scannable names for found items, such as "Black umbrella", built
/// from the first colour and the category. Mirrors the staff app's titles.
class ItemTitles {
  static const _nouns = {
    'umbrella': 'umbrella',
    'backpack': 'backpack',
    'handbag': 'handbag',
    'tote_or_shopping_bag': 'tote bag',
    'suitcase_or_luggage': 'suitcase',
    'wallet_or_purse': 'wallet',
    'keys': 'keys',
    'phone': 'phone',
    'tablet_or_laptop': 'laptop or tablet',
    'earbuds_or_headphones': 'earbuds',
    'charger_or_cable': 'charger',
    'smartwatch_or_watch': 'watch',
    'jewellery': 'jewellery',
    'glasses_or_sunglasses': 'glasses',
    'jacket_or_coat': 'jacket',
    'hat_or_cap': 'hat',
    'scarf_or_gloves': 'scarf or gloves',
    'clothing_other': 'clothing',
    'footwear': 'shoes',
    'water_bottle_or_flask': 'water bottle',
    'toy_or_plush': 'plush toy',
    'book_or_document': 'book',
    'id_card_or_pass': 'ID card',
    'bank_card': 'bank card',
    'cash': 'cash',
    'sports_equipment': 'sports gear',
    'stroller_or_pram': 'stroller',
    'medical_device_or_medication': 'medication',
    'cosmetics': 'cosmetics',
    'camera': 'camera',
  };

  static String colourWord(String colour) => switch (colour) {
    'multicolour' => 'multicoloured',
    'transparent' => 'clear',
    _ => colour,
  };

  static String capitalise(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// "Black umbrella"; "Found item" when there is nothing to go on.
  static String title(ItemAttributes? attributes) {
    if (attributes == null) return 'Found item';
    final noun = _nouns[attributes.category] ?? 'item';
    final colour = attributes.colours.isEmpty
        ? null
        : colourWord(attributes.colours.first);
    return capitalise([?colour, noun].join(' '));
  }
}
