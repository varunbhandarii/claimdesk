import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../policy/verification_questions.dart';
import '../../services/public_codes.dart';
import '../../services/public_intake_service.dart';
import 'public_lang.dart';
import 'public_page.dart';
import 'public_strings.dart';
import 'ticket_context.dart';

class TicketAnswerRoute extends PublicRoute {
  TicketAnswerRoute() : super(methods: {Method.post});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final service = PublicIntakeService();
    // The switch on any page rendered here leads back to the ticket itself.
    var locale = PublicLocale.of(
      request,
    ).at(request.url.path.replaceFirst(RegExp(r'/answer$'), ''));
    final report = await service.findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report == null) return PublicPage.notFound(locale: locale);
    final venue = await Venue.db.findById(session, report.venueId);
    if (venue == null) return PublicPage.notFound(locale: locale);
    if (!(request.headers['content-type']?.firstOrNull ?? '')
        .toLowerCase()
        .startsWith('application/x-www-form-urlencoded')) {
      return PublicPage.unavailable(415, locale: locale);
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
    if (oversized) return PublicPage.unavailable(413, locale: locale);
    Map<String, String> fields;
    try {
      fields = Uri.splitQueryString(utf8.decode(bytes));
    } on FormatException {
      fields = {};
    }
    locale = PublicLocale.of(
      request,
      form: fields,
    ).at('/t/${report.publicToken}');
    final t = PublicStrings.of(locale.lang);
    if ((fields['website'] ?? '').trim().isNotEmpty) {
      return PublicPage.redirect(locale.link('/t/${PublicCodes().token()}'));
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
          locale: locale,
        ),
        'sentence': ?sentence,
        'refusal': ?sentence,
      },
      status: status,
      noStore: true,
      locale: locale,
    );
    if (!{
      ReportStatus.possibleMatch,
      ReportStatus.readyForPickup,
    }.contains(report.status)) {
      return render(409, {}, sentence: t['errNoAnswers']);
    }
    final answers = [fields['answer1'] ?? '', fields['answer2'] ?? ''];
    final errors = VerificationQuestions.validate(
      answers,
    ).map((field, _) => MapEntry(field, t['errAnswerLength']!));
    if (errors.isNotEmpty) return render(422, errors);
    if (!await service.answer(session, report, answers)) {
      return render(409, {}, sentence: t['errNoAnswers']);
    }
    return PublicPage.redirect(
      locale.link('/t/${report.publicToken}?answered=1'),
    );
  }
}
