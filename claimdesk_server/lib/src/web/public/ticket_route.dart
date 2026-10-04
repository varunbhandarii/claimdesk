import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../services/public_intake_service.dart';
import 'public_lang.dart';
import 'public_page.dart';
import 'public_views.dart';
import 'ticket_context.dart';

class TicketRoute extends PublicRoute {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final locale = PublicLocale.of(request);
    final report = await PublicIntakeService().findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report == null) return PublicPage.notFound(locale: locale);
    final venue = await Venue.db.findById(session, report.venueId);
    if (venue == null) return PublicPage.notFound(locale: locale);
    return PublicPage.html(
      'ticket',
      {
        ...await TicketContext.values(
          session,
          report,
          venue,
          editing: request.queryParameters.raw['edit'] == '1',
          locale: locale,
        ),
        'duplicate': request.queryParameters.raw['existing'] == '1',
      },
      noStore: true,
      locale: locale,
    );
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
    if (venue == null) {
      return PublicPage.json({'message': 'No ticket here'}, status: 404);
    }
    final values = await TicketContext.values(session, report, venue);
    return PublicPage.json({
      ...TicketView(report, venue).toJson(),
      'answered': values['answered'],
      if (values['receipt'] != null) 'receipt': values['receipt'],
    });
  }
}
