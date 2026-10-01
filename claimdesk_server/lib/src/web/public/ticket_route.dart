import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../services/public_intake_service.dart';
import 'public_page.dart';
import 'public_views.dart';

class TicketRoute extends PublicRoute {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final report = await PublicIntakeService().findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report == null) return PublicPage.notFound();
    final venue = await Venue.db.findById(session, report.venueId);
    if (venue == null) return PublicPage.notFound();
    return PublicPage.html('ticket', {
      ...TicketView(report, venue).toMap(),
      'duplicate': request.queryParameters.raw['existing'] == '1',
    }, noStore: true);
  }
}

class TicketJsonRoute extends PublicRoute {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final report = await PublicIntakeService().findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report == null) {
      return PublicPage.json({'message': 'No ticket here'}, status: 404);
    }
    final venue = await Venue.db.findById(session, report.venueId);
    return venue == null
        ? PublicPage.json({'message': 'No ticket here'}, status: 404)
        : PublicPage.json(TicketView(report, venue).toJson());
  }
}
