import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import 'public_page.dart';
import 'public_views.dart';

Future<Venue?> publicVenue(Session session, Request request) async {
  final slug = request.pathParameters.raw[#slug] ?? '';
  if (!RegExp(r'^[a-z0-9-]{3,40}$').hasMatch(slug)) return null;
  return Venue.db.findFirstRow(session, where: (t) => t.slug.equals(slug));
}

class VenuePageRoute extends PublicRoute {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final venue = await publicVenue(session, request);
    return venue == null
        ? PublicPage.notFound()
        : PublicPage.html('venue', VenueView.of(venue));
  }
}
