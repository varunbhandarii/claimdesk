import 'dart:convert';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cached desk metadata lets a restored session show its desk when offline.
/// Every data call still goes through the server's membership guard.
Future<(StaffMembership, Venue)?> rememberedVenue(UuidValue userId) async {
  final preferences = await SharedPreferences.getInstance();
  final encoded = preferences.getString('desk_$userId');
  if (encoded == null) return null;
  final value = jsonDecode(encoded) as Map<String, dynamic>;
  final membership = StaffMembership.fromJson(
    value['membership'] as Map<String, dynamic>,
  );
  final venue = Venue.fromJson(value['venue'] as Map<String, dynamic>);
  if (membership.authUserId != userId || membership.venueId != venue.id) {
    return null;
  }
  return (membership, venue);
}

Future<void> rememberVenue(
  UuidValue userId,
  StaffMembership membership,
  Venue venue,
) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString('venue_$userId', venue.id.toString());
  await preferences.setString(
    'desk_$userId',
    jsonEncode({'membership': membership.toJson(), 'venue': venue.toJson()}),
  );
}

Future<void> forgetDesk(UuidValue userId) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove('desk_$userId');
}
