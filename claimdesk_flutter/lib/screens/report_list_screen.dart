import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../app/routes.dart';
import '../data/errors.dart';
import '../ui/report_card.dart';
import '../ui/status.dart';
import '../ui/categories.dart';
import '../ui/offline_banner.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});
  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _code = TextEditingController();
  bool _finding = false;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _open(LostReport report) async {
    final session = VenueScope.of(context);
    await openDeskScreen(
      context,
      session,
      ReportDetailScreen(reportId: report.id!),
    );
    if (mounted) await session.refreshReports();
  }

  Future<void> _find() async {
    final session = VenueScope.of(context);
    setState(() => _finding = true);
    await runGuarded(context, () async {
      final report = await session.client.report.findByRefCode(
        session.venue.id!,
        _code.text,
      );
      if (!mounted) return;
      if (report == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No report with that reference at this venue.'),
          ),
        );
      } else {
        await _open(report);
      }
    }, onDenied: session.onDenied);
    if (mounted) setState(() => _finding = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          children: [
            if (s.offline || s.live.reconnecting)
              OfflineBanner(
                onRetry: () {
                  s.live.connectivityChanged(true);
                  s.refreshReports();
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.venue.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('${s.reports.length} reports in this view'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _code,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: 'Find by reference code',
                            counterText: '',
                          ),
                          onSubmitted: (_) => _find(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _finding ? null : _find,
                        child: const Text('Find'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      DropdownButton<ReportStatus?>(
                        value: s.reportStatusFilter,
                        hint: const Text('All open'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All open'),
                          ),
                          for (final status in ReportStatus.values)
                            DropdownMenuItem(
                              value: status,
                              child: Text(reportStatusLabel(status)),
                            ),
                        ],
                        onChanged: (value) {
                          s.reportStatusFilter = value;
                          s.refreshReports();
                        },
                      ),
                      DropdownButton<UuidValue?>(
                        value: s.reportZoneFilter,
                        hint: const Text('All zones'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All zones'),
                          ),
                          for (final zone in s.zones)
                            DropdownMenuItem(
                              value: zone.id,
                              child: Text(zone.name),
                            ),
                        ],
                        onChanged: (value) {
                          s.reportZoneFilter = value;
                          s.refreshReports();
                        },
                      ),
                      DropdownButton<String?>(
                        value: s.reportCategoryFilter,
                        hint: const Text('All categories'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All categories'),
                          ),
                          for (final entry in categories.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                        ],
                        onChanged: (value) {
                          s.reportCategoryFilter = value;
                          s.refreshReports();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (s.reportsRefreshing && !s.reportsLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: s.reportsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: s.refreshReports,
                      child: s.reports.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Text(
                                        s.reportError == null
                                            ? 'No reports yet. Reports filed through the venue page appear here.'
                                            : errorMessage(s.reportError!),
                                      ),
                                      if (s.reportError != null)
                                        FilledButton(
                                          onPressed: s.refreshReports,
                                          child: const Text('Retry'),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: s.reports.length,
                              itemBuilder: (_, index) => ReportCard(
                                report: s.reports[index],
                                zoneName: s.zoneName(s.reports[index].zoneId),
                                onTap: () => _open(s.reports[index]),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
