import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';

class OwnerAnswers extends StatelessWidget {
  const OwnerAnswers({super.key, required this.answers, this.postedAt});
  final List<ReportAnswer> answers;
  final DateTime? postedAt;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner answers · staff only',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (answers.isEmpty)
            Text(
              'Not answered yet${postedAt == null ? '' : '; questions have been on the ticket since ${postedAt!.toLocal().toString().split('.').first}'}',
            ),
          for (final answer in answers) ...[
            const SizedBox(height: 12),
            Text(
              answer.question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(answer.answer),
            Text(
              'Answered ${answer.createdAt.toLocal().toString().split('.').first}',
            ),
          ],
        ],
      ),
    ),
  );
}
