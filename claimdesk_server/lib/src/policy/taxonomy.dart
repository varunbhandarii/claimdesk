class Taxonomy {
  static const groups = <String, String>{
    'umbrella': 'Umbrellas & rain gear',
    'backpack': 'Bags',
    'handbag': 'Bags',
    'tote_or_shopping_bag': 'Bags',
    'suitcase_or_luggage': 'Bags',
    'wallet_or_purse': 'Wallets, cards & money',
    'keys': 'Keys & access',
    'phone': 'Phones & tablets',
    'tablet_or_laptop': 'Computers & accessories',
    'earbuds_or_headphones': 'Audio',
    'charger_or_cable': 'Computers & accessories',
    'smartwatch_or_watch': 'Wearables & small electronics',
    'jewellery': 'Jewelry & watches',
    'glasses_or_sunglasses': 'Eyewear',
    'jacket_or_coat': 'Clothing',
    'hat_or_cap': 'Clothing',
    'scarf_or_gloves': 'Clothing',
    'clothing_other': 'Clothing',
    'footwear': 'Footwear',
    'water_bottle_or_flask': 'Bottles & food containers',
    'toy_or_plush': 'Toys, gifts & miscellaneous',
    'book_or_document': 'Books, stationery & school supplies',
    'id_card_or_pass': 'ID & documents',
    'bank_card': 'Wallets, cards & money',
    'cash': 'Wallets, cards & money',
    'sports_equipment': 'Sports, bikes & mobility',
    'stroller_or_pram': 'Sports, bikes & mobility',
    'medical_device_or_medication': 'Health & personal care',
    'cosmetics': 'Health & personal care',
    'camera': 'Wearables & small electronics',
    'other': 'Toys, gifts & miscellaneous',
  };
  static const synonyms = <String, List<String>>{
    'umbrella': ['brolly', 'parasol'],
    'backpack': ['rucksack', 'schoolbag'],
    'handbag': ['purse', 'shoulder bag'],
    'tote_or_shopping_bag': ['tote', 'shopping bag'],
    'suitcase_or_luggage': ['suitcase', 'luggage', 'carry on'],
    'wallet_or_purse': ['wallet', 'billfold'],
    'keys': ['fob', 'keychain', 'lanyard'],
    'phone': ['mobile', 'cellphone', 'smartphone'],
    'tablet_or_laptop': ['tablet', 'laptop', 'computer'],
    'earbuds_or_headphones': ['airpods', 'earphones', 'headphones', 'earbuds'],
    'charger_or_cable': ['brick', 'adapter', 'usb-c', 'charger', 'cable'],
    'smartwatch_or_watch': ['smartwatch', 'watch', 'fitness tracker'],
    'jewellery': ['jewelry', 'ring', 'necklace', 'bracelet'],
    'glasses_or_sunglasses': ['spectacles', 'glasses', 'sunglasses'],
    'jacket_or_coat': ['jacket', 'coat', 'parka'],
    'hat_or_cap': ['hat', 'cap', 'beanie'],
    'scarf_or_gloves': ['scarf', 'gloves', 'mittens'],
    'clothing_other': ['hoodie', 'shirt', 'sweatshirt'],
    'footwear': ['shoe', 'sneaker', 'boot'],
    'water_bottle_or_flask': ['hydro flask', 'stanley', 'tumbler', 'thermos'],
    'toy_or_plush': ['toy', 'plush', 'stuffed animal'],
    'book_or_document': ['book', 'notebook', 'document'],
    'id_card_or_pass': ['student id', 'campus card', 'wolfie card', 'passport'],
    'bank_card': ['credit card', 'debit card', 'bank card'],
    'cash': ['money', 'currency'],
    'sports_equipment': ['ball', 'racket', 'helmet'],
    'stroller_or_pram': ['stroller', 'pram', 'pushchair'],
    'medical_device_or_medication': ['medicine', 'medication', 'inhaler'],
    'cosmetics': ['makeup', 'lipstick', 'toiletries'],
    'camera': ['camera', 'lens'],
    'other': ['miscellaneous'],
  };
  static const restricted = {
    'wallet_or_purse',
    'bank_card',
    'cash',
    'id_card_or_pass',
    'medical_device_or_medication',
    'jewellery',
  };
  static const colours = [
    'black',
    'white',
    'grey',
    'silver',
    'gold',
    'red',
    'orange',
    'yellow',
    'green',
    'blue',
    'navy',
    'purple',
    'pink',
    'brown',
    'beige',
    'multicolour',
    'transparent',
  ];
  static bool isRestricted(String category) => restricted.contains(category);
  static String label(String category) =>
      category.replaceAll('_or_', ' or ').replaceAll('_', ' ');
  static String rollUp(String category) => groups[category] ?? groups['other']!;
  static String canonicalize(String text) {
    var result = text.toLowerCase();
    final aliases = [
      for (final e in synonyms.entries)
        for (final alias in e.value) (alias, e.key),
    ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
    for (final (alias, category) in aliases) {
      result = result.replaceAll(
        RegExp('\\b${RegExp.escape(alias)}\\b'),
        category,
      );
    }
    return result;
  }
}
