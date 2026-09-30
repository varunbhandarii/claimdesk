import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claimdesk_flutter/data/venue_choice.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'remembered desk belongs only to the signed-in user and clears on sign-out',
    () async {
      final member = StaffMembership(
        authUserId: itemId,
        venueId: venueId,
        displayName: 'Demo staff',
      );
      final venue = Venue(id: venueId, name: 'Demo desk', slug: 'demo');
      await rememberVenue(itemId, member, venue);
      final restored = await rememberedVenue(itemId);
      expect(restored!.$1.authUserId, itemId);
      expect(restored.$2.id, venueId);
      expect(restored.$2.name, 'Demo desk');
      expect(await rememberedVenue(venueId), isNull);
      await forgetDesk(itemId);
      expect(await rememberedVenue(itemId), isNull);
    },
  );
  test('cached membership metadata cannot be used for another user', () async {
    await rememberVenue(
      venueId,
      StaffMembership(
        authUserId: itemId,
        venueId: venueId,
        displayName: 'Other user',
      ),
      Venue(id: venueId, name: 'Desk', slug: 'desk'),
    );
    expect(await rememberedVenue(venueId), isNull);
  });
}
