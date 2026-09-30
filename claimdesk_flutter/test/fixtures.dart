import 'package:claimdesk_client/claimdesk_client.dart';

final venueId = UuidValue.fromString('12345678-1234-7123-8123-123456789abc');
final itemId = UuidValue.fromString('12345678-1234-7123-8123-123456789abd');
ItemAttributes attributes({String category = 'backpack'}) => ItemAttributes(
  category: category,
  colours: ['black', 'navy'],
  brand: 'Test brand',
  marks: ['Small red patch'],
  description: 'A black backpack',
  personalDataKinds: ['name'],
  keywords: [],
  source: 'staff_typed',
);
FoundItem item({
  ItemStatus status = ItemStatus.unclaimed,
  bool restricted = false,
  DateTime? updated,
}) => FoundItem(
  id: itemId,
  venueId: venueId,
  refCode: 'ABC123',
  loggedByAuthUserId: venueId,
  attributes: attributes(),
  status: status,
  restricted: restricted,
  foundAt: DateTime(2026, 9, 30, 10),
  updatedAt: updated ?? DateTime(2026, 9, 30, 10),
);
