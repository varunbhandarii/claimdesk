import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../policy/verification_questions.dart';
import 'public_views.dart';

class TicketContext {
  static Future<Map<String, dynamic>> values(
    Session session,
    LostReport report,
    Venue venue, {
    Map<String, String> fields = const {},
    Map<String, String> errors = const {},
    bool editing = false,
  }) async {
    final active = {
      ReportStatus.possibleMatch,
      ReportStatus.readyForPickup,
    }.contains(report.status);
    final match = active
        ? await ItemMatch.db.findFirstRow(
            session,
            where: (t) =>
                t.reportId.equals(report.id!) &
                t.venueId.equals(report.venueId) &
                t.state.equals(MatchState.confirmed),
          )
        : null;
    final answers = match == null
        ? <ReportAnswer>[]
        : await ReportAnswer.db.find(
            session,
            where: (t) => t.matchId.equals(match.id!),
            orderBy: (t) => t.createdAt,
          );
    final questions = VerificationQuestions.forCategory(
      report.attributes?.category ?? report.categoryHint ?? 'other',
    );
    final item = match == null || report.status != ReportStatus.readyForPickup
        ? null
        : await FoundItem.db.findById(session, match.itemId);
    final photo =
        item != null &&
        item.venueId == report.venueId &&
        item.status == ItemStatus.matched &&
        !item.restricted &&
        item.thumbPath != null;
    final receipt = report.status == ReportStatus.returned
        ? await ReleaseRecord.db.findFirstRow(
            session,
            where: (t) =>
                t.reportId.equals(report.id!) &
                t.venueId.equals(report.venueId),
          )
        : null;
    return {
      ...TicketView(report, venue).toMap(),
      'answered': answers.length == 2,
      'photo': photo,
      'photoPath': '/t/${report.publicToken}/photo',
      'receipt': receipt == null
          ? null
          : {
              'returnedAt': TicketView(report, venue).date(receipt.releasedAt),
              'idTypeSeen': TicketView.idTypeLabel(receipt.idTypeSeen),
            },
      'ownerEcho':
          report.status == ReportStatus.possibleMatch &&
              answers.length == 2 &&
              !editing
          ? answers
                .map((a) => {'question': a.question, 'answer': a.answer})
                .toList()
          : <Map<String, String>>[],
      'answerForm':
          match != null &&
          (answers.length != 2 || editing || errors.isNotEmpty),
      'answerAction': '/t/${report.publicToken}/answer',
      'changeAnswers':
          match != null && answers.length == 2 && !editing && errors.isEmpty,
      'questions': [
        for (var i = 0; i < 2; i++)
          {
            'field': 'answer${i + 1}',
            'question': questions[i],
            'value':
                fields['answer${i + 1}'] ??
                (editing &&
                        report.status == ReportStatus.possibleMatch &&
                        answers.length == 2
                    ? answers[i].answer
                    : ''),
            'error': errors['answer${i + 1}'],
          },
      ],
    };
  }
}
