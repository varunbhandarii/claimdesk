import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'item_card.dart';
import 'status.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.zoneName,
    this.onTap,
    this.now,
  });
  final LostReport report;
  final String zoneName;
  final VoidCallback? onTap;
  final DateTime? now;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.refCode, style: Theme.of(context).textTheme.titleLarge),
            Text(
              report.rawText.split('\n').first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('$zoneName · Filed ${timeAgo(report.createdAt, now: now)}'),
            Wrap(
              spacing: 6,
              children: [
                ReportStatusChip(report.status),
                if (report.categoryHint != null)
                  Chip(label: Text(categoryLabel(report.categoryHint!))),
                for (final colour in report.colourHints)
                  Chip(label: Text(colour)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
