import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/categories.dart';
import '../ui/desk_chip.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/item_card.dart';
import '../ui/report_card.dart';
import '../ui/status.dart';
import 'report_detail_screen.dart';

final _codePattern = RegExp(r'^[A-Za-z0-9]{6}$');

/// Lost reports filed through the venue page.
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key, this.wide = false});
  final bool wide;
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
    final code = _code.text.trim();
    if (!_codePattern.hasMatch(code)) return;
    final session = VenueScope.of(context);
    setState(() => _finding = true);
    await runGuarded(context, () async {
      final report = await session.client.report.findByRefCode(
        session.venue.id!,
        code,
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

  Future<void> _filters(VenueSession session) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        VenueScope(session: session, child: const _ReportFiltersSheet()),
  );

  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    final c = context.desk;
    final side = widget.wide ? 32.0 : 16.0;
    final query = _code.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? s.reports
        : s.reports
              .where(
                (r) =>
                    r.refCode.toLowerCase().contains(query) ||
                    r.rawText.toLowerCase().contains(query),
              )
              .toList();
    final filters = [
      s.reportZoneFilter,
      s.reportCategoryFilter,
    ].where((f) => f != null).length;
    final looksLikeCode = _codePattern.hasMatch(_code.text.trim());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(side, widget.wide ? 26 : 4, side, 12),
          child: PageTitle(
            'Reports',
            trailing: s.reportStatusFilter == null
                ? '${s.reports.length} open'
                : '${s.reports.length} in this view',
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: side),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.wide ? 520 : double.infinity,
              ),
              child: TextField(
                controller: _code,
                maxLength: 80,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search, or type a code like SMP854',
                  counterText: '',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: looksLikeCode
                      ? Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: TextButton(
                            onPressed: _finding ? null : _find,
                            child: Text(_finding ? 'Finding…' : 'Find'),
                          ),
                        )
                      : _code.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(_code.clear),
                        ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _find(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ChipRow(
          padding: side,
          children: [
            DeskChip(
              label: filters == 0 ? 'Filters' : 'Filters · $filters',
              icon: Icons.tune,
              selected: false,
              onTap: () => _filters(s),
            ),
            for (final status in [null, ...ReportStatus.values])
              DeskChip(
                label: status == null ? 'All open' : reportStatusLabel(status),
                selected: s.reportStatusFilter == status,
                onTap: () {
                  s.reportStatusFilter = status;
                  s.refreshReports();
                },
              ),
          ],
        ),
        if (filters > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(side, 6, side, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (s.reportZoneFilter != null)
                  DeskChip(
                    label: s.zoneName(s.reportZoneFilter),
                    icon: Icons.place_outlined,
                    selected: true,
                    onTap: null,
                    onDeleted: () {
                      s.reportZoneFilter = null;
                      s.refreshReports();
                    },
                  ),
                if (s.reportCategoryFilter != null)
                  DeskChip(
                    label: categoryLabel(s.reportCategoryFilter!),
                    selected: true,
                    onTap: null,
                    onDeleted: () {
                      s.reportCategoryFilter = null;
                      s.refreshReports();
                    },
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 2,
          child: s.reportsRefreshing && !s.reportsLoading
              ? const LinearProgressIndicator(minHeight: 2)
              : null,
        ),
        Expanded(
          child: s.reportsLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: s.refreshReports,
                  child: visible.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (s.reportError != null)
                              RetryMessage(
                                message: errorMessage(s.reportError!),
                                onRetry: s.refreshReports,
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  query.isNotEmpty
                                      ? 'No reports in this view match “${_code.text.trim()}”.'
                                      : 'No reports yet. Reports filed through the venue page appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: c.ink2),
                                ),
                              ),
                          ],
                        )
                      : CardGrid(
                          physics: const AlwaysScrollableScrollPhysics(),
                          minCardWidth: widget.wide ? 380 : 300,
                          spacing: 10,
                          padding: EdgeInsets.fromLTRB(side, 6, side, 40),
                          itemCount: visible.length,
                          itemBuilder: (_, index) => ReportCard(
                            report: visible[index],
                            zoneName: s.zoneName(visible[index].zoneId),
                            onTap: () => _open(visible[index]),
                          ),
                        ),
                ),
        ),
      ],
    );
  }
}

class _ReportFiltersSheet extends StatelessWidget {
  const _ReportFiltersSheet();
  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    void apply(VoidCallback change) {
      change();
      s.refreshReports();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: context.type.headingAt(22)),
            const SizedBox(height: 18),
            const DeskLabel('Where they lost it'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DeskChip(
                  label: 'All zones',
                  selected: s.reportZoneFilter == null,
                  onTap: () => apply(() => s.reportZoneFilter = null),
                ),
                for (final zone in s.zones)
                  DeskChip(
                    label: zone.name,
                    selected: s.reportZoneFilter == zone.id,
                    onTap: () => apply(() => s.reportZoneFilter = zone.id),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const DeskLabel('Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DeskChip(
                  label: 'All categories',
                  selected: s.reportCategoryFilter == null,
                  onTap: () => apply(() => s.reportCategoryFilter = null),
                ),
                for (final entry in categories.entries)
                  DeskChip(
                    label: entry.value,
                    selected: s.reportCategoryFilter == entry.key,
                    onTap: () =>
                        apply(() => s.reportCategoryFilter = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Show reports'),
            ),
          ],
        ),
      ),
    );
  }
}
