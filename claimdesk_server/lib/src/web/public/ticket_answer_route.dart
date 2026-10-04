import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../policy/verification_questions.dart';
import '../../services/public_codes.dart';
import '../../services/public_intake_service.dart';
import 'public_page.dart';
import 'ticket_context.dart';

class TicketAnswerRoute extends PublicRoute {
  TicketAnswerRoute() : super(methods: {Method.post});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final service = PublicIntakeService();
    final report = await service.findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report == null) return PublicPage.notFound();
    final venue = await Venue.db.findById(session, report.venueId);
    if (venue == null) return PublicPage.notFound();
    if (!(request.headers['content-type']?.firstOrNull ?? '')
        .toLowerCase()
        .startsWith('application/x-www-form-urlencoded')) {
      return PublicPage.html('unavailable', {}, status: 415, noStore: true);
    }
    final bytes = <int>[];
    var oversized = false;
    await for (final chunk in request.read()) {
      if (!oversized && bytes.length + chunk.length <= 16384) {
        bytes.addAll(chunk);
      } else {
        oversized = true;
        bytes.clear();
      }
    }
    if (oversized) {
      return PublicPage.html('unavailable', {}, status: 413, noStore: true);
    }
    Map<String, String> fields;
    try {
      fields = Uri.splitQueryString(utf8.decode(bytes));
    } on FormatException {
      fields = {};
    }
    if ((fields['website'] ?? '').trim().isNotEmpty) {
      return PublicPage.redirect('/t/${PublicCodes().token()}');
    }
    Future<Result> render(
      int status,
      Map<String, String> errors, {
      String? sentence,
    }) async => PublicPage.html(
      'ticket',
      {
        ...await TicketContext.values(
          session,
          report,
          venue,
          fields: fields,
          errors: errors,
          editing: true,
        ),
        'sentence': ?sentence,
        'refusal': ?sentence,
      },
      status: status,
      noStore: true,
    );
    if (!{
      ReportStatus.possibleMatch,
      ReportStatus.readyForPickup,
    }.contains(report.status)) {
      return render(
        409,
        {},
        sentence: 'The desk is not asking for answers right now.',
      );
    }
    final answers = [fields['answer1'] ?? '', fields['answer2'] ?? ''];
    final errors = VerificationQuestions.validate(answers);
    if (errors.isNotEmpty) return render(422, errors);
    if (!await service.answer(session, report, answers)) {
      return render(
        409,
        {},
        sentence: 'The desk is not asking for answers right now.',
      );
    }
    return PublicPage.redirect('/t/${report.publicToken}?answered=1');
  }
}
