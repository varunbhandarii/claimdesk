import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'pills.dart';

/// Staff-only evidence of ownership: the owner's hidden details, their
/// answers to the verification questions and, for comparison, the desk's
/// private notes.
class OwnerAnswers extends StatelessWidget {
  const OwnerAnswers({
    super.key,
    required this.answers,
    this.postedAt,
    this.ownerOnlyDetails,
    this.showOwnerOnly = false,
    this.privateNotes,
  });
  final List<ReportAnswer> answers;
  final DateTime? postedAt;
  final String? ownerOnlyDetails;
  final bool showOwnerOnly;
  final String? privateNotes;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    Widget quote(String text) => Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: c.ticket, width: 3)),
      ),
      child: CopyableText(
        text,
        style: context.type.body.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c.ink,
        ),
      ),
    );
    return DeskCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconDisc(Icons.lock_outline, size: 30, iconSize: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Owner’s proof',
                  style: context.type.headingAt(18),
                ),
              ),
              const StatusPill('Staff only'),
            ],
          ),
          if (showOwnerOnly) ...[
            const SizedBox(height: 14),
            const DeskLabel('Only the owner would know'),
            const SizedBox(height: 6),
            ownerOnlyDetails == null || ownerOnlyDetails!.trim().isEmpty
                ? Text(
                    'Not provided',
                    style: TextStyle(color: c.ink3),
                  )
                : quote(ownerOnlyDetails!),
          ],
          const SizedBox(height: 14),
          if (answers.isEmpty)
            Text(
              'Not answered yet${postedAt == null ? '' : '; questions have been on the ticket since ${dateTimeLabel(postedAt!, midSentence: true)}'}',
              style: context.type.body.copyWith(fontSize: 14, color: c.ink2),
            ),
          for (var i = 0; i < answers.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            DeskLabel('Answer ${i + 1}'),
            const SizedBox(height: 4),
            Text(
              answers[i].question,
              style: context.type.small.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 6),
            quote(answers[i].answer),
            const SizedBox(height: 4),
            Text(
              'Answered ${dateTimeLabel(answers[i].createdAt, midSentence: true)}',
              style: context.type.small.copyWith(color: c.ink3),
            ),
          ],
          if (privateNotes != null && privateNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DeskLabel('Compare with your private notes'),
                  const SizedBox(height: 4),
                  Text(
                    privateNotes!,
                    style: context.type.body.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
