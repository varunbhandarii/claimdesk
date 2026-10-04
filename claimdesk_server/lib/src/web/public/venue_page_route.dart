import 'package:serverpod/serverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../generated/protocol.dart';
import '../../policy/item_titles.dart';
import '../../policy/taxonomy.dart';
import 'public_page.dart';
import 'public_views.dart';
import 'report_form_input.dart';

Future<Venue?> publicVenue(Session session, Request request) async {
  final slug = request.pathParameters.raw[#slug] ?? '';
  if (!RegExp(r'^[a-z0-9-]{3,40}$').hasMatch(slug)) return null;
  return Venue.db.findFirstRow(session, where: (t) => t.slug.equals(slug));
}

/// Items handed in recently, described only by colour, kind, zone and day.
/// Restricted items, anything worth $100 or more and categories that may hold
/// personal data are never listed.
Future<List<Map<String, String>>> recentlyHandedIn(
  Session session,
  Venue venue, {
  DateTime? now,
  int limit = 6,
}) async {
  final at = (now ?? DateTime.now()).toUtc();
  final rows = await FoundItem.db.find(
    session,
    where: (t) =>
        t.venueId.equals(venue.id!) &
        t.status.inSet({ItemStatus.unclaimed, ItemStatus.matched}) &
        t.restricted.equals(false) &
        (t.foundAt >= at.subtract(const Duration(days: 14))),
    orderByList: (t) => [t.foundAt.desc(), t.id.desc()],
    limit: 40,
  );
  final shown = rows
      .where(
        (item) =>
            item.attributes != null &&
            !item.attributes!.containsPersonalData &&
            !Taxonomy.isRestricted(item.attributes!.category) &&
            item.valueBand.index < ValueBand.from100to499.index,
      )
      .take(limit)
      .toList();
  if (shown.isEmpty) return const [];
  final zones = {
    for (final zone in await Zone.db.find(
      session,
      where: (t) => t.venueId.equals(venue.id!),
    ))
      zone.id: zone.name,
  };
  final location = ReportFormInput.location(venue.timezone);
  final today = tz.TZDateTime.from(at, location);
  return [
    for (final item in shown)
      {
        'title': ItemTitles.title(item.attributes),
        'colour': item.attributes!.colours.firstOrNull ?? 'none',
        'where': [
          ?zones[item.zoneId],
          shortDay(tz.TZDateTime.from(item.foundAt, location), now: today),
        ].join(' · '),
      },
  ];
}

class VenuePageRoute extends PublicRoute {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final venue = await publicVenue(session, request);
    if (venue == null) return PublicPage.notFound();
    final recent = await recentlyHandedIn(session, venue);
    return PublicPage.html('venue', {
      ...VenueView.of(venue),
      'recent': recent,
      'hasRecent': recent.isNotEmpty,
    });
  }
}
