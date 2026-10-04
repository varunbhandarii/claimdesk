import 'package:claimdesk_client/claimdesk_client.dart';
import 'categories.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

int _calendarDays(DateTime later, DateTime earlier) => DateTime.utc(
  later.year,
  later.month,
  later.day,
).difference(DateTime.utc(earlier.year, earlier.month, earlier.day)).inDays;

/// "Sep 30", with the year added when it is not the current one.
String shortDate(DateTime at, {DateTime? now}) {
  final d = at.toLocal(), n = (now ?? DateTime.now()).toLocal();
  final day = '${_months[d.month - 1]} ${d.day}';
  return d.year == n.year ? day : '$day, ${d.year}';
}

/// "3:35 PM".
String clockTime(DateTime at) {
  final d = at.toLocal();
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$hour:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// "Today, 3:35 PM", "Yesterday, 9:02 AM" or "Sep 30, 3:35 PM". Use
/// [midSentence] after a verb, as in "Filed today, 3:35 PM".
String dateTimeLabel(DateTime at, {DateTime? now, bool midSentence = false}) {
  final d = at.toLocal(), n = (now ?? DateTime.now()).toLocal();
  final days = _calendarDays(n, d);
  if (days == 0) return '${midSentence ? 'today' : 'Today'}, ${clockTime(d)}';
  if (days == 1) {
    return '${midSentence ? 'yesterday' : 'Yesterday'}, ${clockTime(d)}';
  }
  return '${shortDate(d, now: n)}, ${clockTime(d)}';
}

/// "Saturday, October 3".
String longDay(DateTime at) {
  final d = at.toLocal();
  return '${_weekdays[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}';
}

/// "just now", "12 min ago", "3 h ago", "yesterday", "4 days ago", then a date.
String timeAgo(DateTime at, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final age = n.difference(at);
  if (age.inMinutes < 1) return 'just now';
  if (age.inHours < 1) return '${age.inMinutes} min ago';
  if (age.inDays < 1) return '${age.inHours} h ago';
  final days = _calendarDays(n.toLocal(), at.toLocal());
  if (days <= 1) return 'yesterday';
  if (days < 7) return '$days days ago';
  return shortDate(at, now: n);
}

/// Compact age for dense rows: "12 min", "3 h", "1 day", "5 days".
String ageShort(DateTime at, {DateTime? now}) {
  final age = (now ?? DateTime.now()).difference(at);
  if (age.inMinutes < 1) return 'now';
  if (age.inHours < 1) return '${age.inMinutes} min';
  if (age.inDays < 1) return '${age.inHours} h';
  return age.inDays == 1 ? '1 day' : '${age.inDays} days';
}

const _nouns = {
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

String capitalise(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// Adjective for a stored colour value: "black", "multicoloured", "clear".
String colourWord(String colour) => switch (colour) {
  'multicolour' => 'multicoloured',
  'transparent' => 'clear',
  _ => colour,
};

/// Display name for a stored colour value: "Black", "Multicoloured", "Clear".
String colourLabel(String colour) => capitalise(colourWord(colour));

/// A short, scannable name such as "Black umbrella", built from the caption's
/// first colour and category.
String attributesTitle(ItemAttributes? attributes) {
  if (attributes == null) return 'New item';
  final noun = _nouns[attributes.category];
  if (noun == null) {
    final description = attributes.description.trim();
    if (description.isEmpty) return 'Found item';
    final first = description.split(RegExp(r'[.;:\n]')).first.trim();
    if (first.length <= 40) return capitalise(first);
    final cut = first.substring(0, 40);
    final space = cut.lastIndexOf(' ');
    return '${capitalise(space > 20 ? cut.substring(0, space) : cut)}…';
  }
  final colour = attributes.colours.isEmpty
      ? null
      : colourWord(attributes.colours.first);
  return capitalise([?colour, noun].join(' '));
}

String itemTitle(FoundItem item) => attributesTitle(item.attributes);

/// "Umbrellas & rain gear · curved wooden handle".
String itemSubtitle(ItemAttributes? attributes) {
  if (attributes == null) return 'Details pending';
  final mark = attributes.marks.where((m) => m.trim().isNotEmpty).firstOrNull;
  final group = categoryLabel(attributes.category);
  return mark == null ? group : '$group · ${mark.trim()}';
}

/// Report text without surrounding whitespace, as one line.
String reportLine(LostReport report) =>
    report.rawText.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Readable disposal recommendation, such as "Donate or recycle".
String disposalLabel(String action) => switch (action) {
  'donate_or_recycle' => 'Donate or recycle',
  'police_or_health' => 'Hand to police or health service',
  'notify_issuer_then_shred' => 'Notify the issuer, then shred',
  'issuer' => 'Return to the issuer',
  'facilities' => 'Hand to facilities',
  _ => capitalise(action.replaceAll('_', ' ')),
};
