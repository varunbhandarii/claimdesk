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

  /// Spanish nouns with the form their colour agrees with.
  static const _nounsEs = <String, (String, _Agreement)>{
    'umbrella': ('paraguas', _Agreement.masculine),
    'backpack': ('mochila', _Agreement.feminine),
    'handbag': ('bolsa de mano', _Agreement.feminine),
    'tote_or_shopping_bag': ('bolsa de tela', _Agreement.feminine),
    'suitcase_or_luggage': ('maleta', _Agreement.feminine),
    'wallet_or_purse': ('billetera', _Agreement.feminine),
    'keys': ('llaves', _Agreement.femininePlural),
    'phone': ('teléfono', _Agreement.masculine),
    'tablet_or_laptop': ('laptop o tableta', _Agreement.feminine),
    'earbuds_or_headphones': ('audífonos', _Agreement.masculinePlural),
    'charger_or_cable': ('cargador', _Agreement.masculine),
    'smartwatch_or_watch': ('reloj', _Agreement.masculine),
    'jewellery': ('joya', _Agreement.feminine),
    'glasses_or_sunglasses': ('lentes', _Agreement.masculinePlural),
    'jacket_or_coat': ('chaqueta', _Agreement.feminine),
    'hat_or_cap': ('gorra', _Agreement.feminine),
    'scarf_or_gloves': ('bufanda o guantes', _Agreement.masculinePlural),
    'clothing_other': ('ropa', _Agreement.feminine),
    'footwear': ('zapatos', _Agreement.masculinePlural),
    'water_bottle_or_flask': ('botella de agua', _Agreement.feminine),
    'toy_or_plush': ('peluche', _Agreement.masculine),
    'book_or_document': ('libro', _Agreement.masculine),
    'id_card_or_pass': ('identificación', _Agreement.feminine),
    'bank_card': ('tarjeta bancaria', _Agreement.feminine),
    'cash': ('efectivo', _Agreement.masculine),
    'sports_equipment': ('equipo deportivo', _Agreement.masculine),
    'stroller_or_pram': ('carriola', _Agreement.feminine),
    'medical_device_or_medication': ('medicamento', _Agreement.masculine),
    'cosmetics': ('cosméticos', _Agreement.masculinePlural),
    'camera': ('cámara', _Agreement.feminine),
  };

  /// Spanish colour adjectives: masculine, feminine, masculine plural,
  /// feminine plural.
  static const _coloursEs = <String, List<String>>{
    'black': ['negro', 'negra', 'negros', 'negras'],
    'white': ['blanco', 'blanca', 'blancos', 'blancas'],
    'grey': ['gris', 'gris', 'grises', 'grises'],
    'silver': ['plateado', 'plateada', 'plateados', 'plateadas'],
    'gold': ['dorado', 'dorada', 'dorados', 'doradas'],
    'red': ['rojo', 'roja', 'rojos', 'rojas'],
    'orange': ['naranja', 'naranja', 'naranja', 'naranja'],
    'yellow': ['amarillo', 'amarilla', 'amarillos', 'amarillas'],
    'green': ['verde', 'verde', 'verdes', 'verdes'],
    'blue': ['azul', 'azul', 'azules', 'azules'],
    'navy': ['azul marino', 'azul marino', 'azul marino', 'azul marino'],
    'purple': ['morado', 'morada', 'morados', 'moradas'],
    'pink': ['rosa', 'rosa', 'rosa', 'rosa'],
    'brown': ['café', 'café', 'café', 'café'],
    'beige': ['beige', 'beige', 'beige', 'beige'],
    'multicolour': ['multicolor', 'multicolor', 'multicolores', 'multicolores'],
    'transparent': [
      'transparente',
      'transparente',
      'transparentes',
      'transparentes',
    ],
  };

  /// "Mochila negra", "Llaves rojas": the noun first, then the first colour
  /// agreeing with it; "Objeto encontrado" when there is nothing to go on.
  static String spanishTitle(ItemAttributes? attributes) {
    if (attributes == null) return 'Objeto encontrado';
    final (noun, agreement) =
        _nounsEs[attributes.category] ?? ('objeto', _Agreement.masculine);
    final colour = attributes.colours.isEmpty
        ? null
        : _coloursEs[attributes.colours.first]?[agreement.index];
    return capitalise([noun, ?colour].join(' '));
  }
}

enum _Agreement { masculine, feminine, masculinePlural, femininePlural }
