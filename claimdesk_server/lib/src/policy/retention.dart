import '../generated/protocol.dart';

({DateTime holdUntil, DateTime? handoffDueAt}) retentionDates(
  FoundItem item,
  Venue venue,
  String category,
) {
  final policy = venue.retentionPolicy ?? defaultRetentionPolicy();
  const aliases = {
    'water_bottle_or_flask': 'bottle',
    'backpack': 'empty_bag',
    'handbag': 'empty_bag',
    'tote_or_shopping_bag': 'empty_bag',
    'suitcase_or_luggage': 'empty_bag',
    'book_or_document': 'book',
    'glasses_or_sunglasses': 'eyewear',
    'jacket_or_coat': 'clothing',
    'hat_or_cap': 'clothing',
    'scarf_or_gloves': 'clothing',
    'clothing_other': 'clothing',
    'id_card_or_pass': 'government_id',
    'medical_device_or_medication': 'medication',
  };
  final days =
      policy.holdDaysByCategory[category] ??
      policy.holdDaysByCategory[aliases[category]] ??
      policy.holdDaysByCategory['default'] ??
      14;
  const lowerBounds = {
    ValueBand.under20: 0,
    ValueBand.from20to99: 2000,
    ValueBand.from100to499: 10000,
    ValueBand.from500to4999: 50000,
    ValueBand.over5000: 500000,
  };
  return (
    holdUntil: item.foundAt.toUtc().add(Duration(days: days)),
    handoffDueAt:
        lowerBounds[item.valueBand]! >= venue.policeHandoffThresholdCents
        ? item.foundAt.toUtc().add(Duration(days: venue.policeHandoffDays))
        : null,
  );
}

/// Configurable demo desk defaults. Calendar and value rules are applied by
/// the retention service; these values alone do not schedule disposal.
RetentionPolicy defaultRetentionPolicy() => RetentionPolicy(
  holdDaysByCategory: {
    'default': 14,
    'bottle': 7,
    'umbrella': 14,
    'single_glove_or_sock': 14,
    'clothing': 30,
    'footwear': 30,
    'empty_bag': 30,
    'book': 30,
    'eyewear': 30,
    'keys': 30,
    'building_keys': 2,
    'campus_id': 1,
    'bank_card': 7,
    'government_id': 30,
    'passport': 30,
    'medication': 0,
    'weapon': 0,
    'vape': 0,
    'alcohol': 0,
    'perishable': 0,
    'liquid': 0,
    'soiled_item': 0,
  },
  disposalByCategory: {
    'default': 'donate_or_recycle',
    'bottle': 'donate_or_recycle',
    'umbrella': 'donate_or_recycle',
    'single_glove_or_sock': 'donate_or_recycle',
    'clothing': 'donate',
    'footwear': 'donate',
    'empty_bag': 'donate',
    'book': 'donate',
    'eyewear': 'donate',
    'keys': 'destroy',
    'building_keys': 'facilities',
    'campus_id': 'issuer',
    'bank_card': 'notify_issuer_then_shred',
    'government_id': 'issuer',
    'passport': 'issuer',
    'medication': 'police_or_health',
    'weapon': 'police_or_health',
    'vape': 'police_or_health',
    'alcohol': 'police_or_health',
    'perishable': 'discard',
    'liquid': 'discard',
    'soiled_item': 'discard',
  },
);
