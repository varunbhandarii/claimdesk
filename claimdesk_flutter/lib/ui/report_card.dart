import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'status.dart';

/// A lost report as a row: its ticket and status, the owner's words, then
/// colours, where and when.
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
  Widget build(BuildContext context) {
    final c = context.desk;
    return DeskCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RefTicket(report.refCode),
              const Spacer(),
              ReportStatusChip(report.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reportLine(report),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.body.copyWith(fontSize: 14.5, height: 1.4),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final colour in report.colourHints) ColourDot(colour),
              Padding(
                padding: EdgeInsets.only(
                  left: report.colourHints.isEmpty ? 0 : 4,
                ),
                child: Text(
                  [
                    if (report.categoryHint != null)
                      categoryLabel(report.categoryHint!),
                    zoneName,
                    'filed ${timeAgo(report.createdAt, now: now)}',
                  ].join(' · '),
                  style: context.type.small.copyWith(color: c.ink3),
                ),
              ),
              if (report.lastMatchOutcome == 'match_failed')
                const MatchingUnavailable(),
            ],
          ),
        ],
      ),
    );
  }
}
