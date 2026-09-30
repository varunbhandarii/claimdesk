/// Display groups select a representative fine category for staff hints.
const categories = <String, String>{
  'umbrella': 'Umbrellas & rain gear',
  'backpack': 'Bags',
  'wallet_or_purse': 'Wallets, cards & money',
  'keys': 'Keys & access',
  'phone': 'Phones & tablets',
  'tablet_or_laptop': 'Computers & accessories',
  'earbuds_or_headphones': 'Audio',
  'smartwatch_or_watch': 'Wearables & small electronics',
  'jewellery': 'Jewelry & watches',
  'glasses_or_sunglasses': 'Eyewear',
  'clothing_other': 'Clothing',
  'footwear': 'Footwear',
  'water_bottle_or_flask': 'Bottles & food containers',
  'book_or_document': 'Books, stationery & school supplies',
  'id_card_or_pass': 'ID & documents',
  'sports_equipment': 'Sports, bikes & mobility',
  'medical_device_or_medication': 'Health & personal care',
  'other': 'Toys, gifts & miscellaneous',
};
String categoryLabel(String fine) =>
    categories[categoryRepresentative(fine)] ?? categories['other']!;
String categoryRepresentative(String fine) => switch (fine) {
  'handbag' || 'tote_or_shopping_bag' || 'suitcase_or_luggage' => 'backpack',
  'bank_card' || 'cash' => 'wallet_or_purse',
  'charger_or_cable' => 'tablet_or_laptop',
  'jacket_or_coat' || 'hat_or_cap' || 'scarf_or_gloves' => 'clothing_other',
  'toy_or_plush' => 'other',
  'stroller_or_pram' => 'sports_equipment',
  'cosmetics' => 'medical_device_or_medication',
  'camera' => 'smartwatch_or_watch',
  _ => fine,
};
String fineLabel(String value) =>
    value.replaceAll('_or_', ' or ').replaceAll('_', ' ');
const colours = [
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
