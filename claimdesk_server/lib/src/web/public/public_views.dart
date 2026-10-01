import 'package:timezone/timezone.dart' as tz;
import '../../generated/protocol.dart';
import '../../policy/taxonomy.dart';
import 'report_form_input.dart';

class VenueView {
  static Map<String, dynamic> of(Venue venue) => {
    'name': venue.name,
    'slug': venue.slug,
    'deskHours': venue.deskHours ?? 'Ask the front desk for opening hours.',
    'pickupInstructions':
        venue.pickupInstructions ??
        'Bring your reference code to the front desk.',
  };
}

class FormView {
  static Map<String, dynamic> of(
    Venue venue,
    List<Zone> zones, {
    Map<String, String> fields = const {},
    Map<String, String> errors = const {},
  }) {
    final groups = <String, String>{};
    for (final entry in Taxonomy.groups.entries) {
      groups.putIfAbsent(entry.value, () => entry.key);
    }
    groups['Clothing'] = 'clothing_other';
    groups['Toys, gifts & miscellaneous'] = 'other';
    return {
      ...VenueView.of(venue),
      'fields': fields,
      'errors': errors,
      'hasErrors': errors.isNotEmpty,
      'errorSummary': errors.entries
          .map((e) => {'field': e.key, 'message': e.value})
          .toList(),
      'categories': groups.entries
          .map(
            (e) => {
              'key': e.value,
              'label': e.key,
              'selected': fields['categoryHint'] == e.value,
            },
          )
          .toList(),
      'zones': zones
          .map(
            (z) => {
              'key': z.id.toString(),
              'label': z.name,
              'selected': fields['zoneId'] == z.id.toString(),
            },
          )
          .toList(),
      'colours': Taxonomy.colours
          .map(
            (c) => {
              'key': c,
              'label': c,
              'checked': fields['colour_$c'] == 'on',
            },
          )
          .toList(),
      'unsureDay': fields['unsureDay'] == 'on',
      'consent': fields['consent'] == 'on',
      'today': _date(
        tz.TZDateTime.now(ReportFormInput.location(venue.timezone)),
      ),
    };
  }
}

String _date(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class TicketView {
  TicketView(this.report, this.venue);
  final LostReport report;
  final Venue venue;
  static const labels = [
    'Received',
    'Searching',
    'Possible match',
    'Ready for pickup',
    'Returned',
    'Closed',
  ];
  String date(DateTime value) {
    final local = tz.TZDateTime.from(
      value,
      ReportFormInput.location(venue.timezone),
    );
    return '${_date(local)} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} ${local.timeZoneName}';
  }

  String get sentence => switch (report.status) {
    ReportStatus.received =>
      'We have your report. The desk checks new items against it; come back here for updates.',
    ReportStatus.searching =>
      'We are checking every item handed in against your report, and we keep checking as new items arrive.',
    ReportStatus.possibleMatch =>
      'The desk may have your item. Come to the desk with photo ID, and answer the two questions below to help staff verify ownership.',
    ReportStatus.readyForPickup =>
      'Your item is ready. Bring photo ID to the desk.',
    ReportStatus.returned =>
      'Returned. Thank you. Last updated ${date(report.updatedAt)}.',
    ReportStatus.closed =>
      'This report was closed on ${date(report.closedAt ?? report.updatedAt)} without a match. File a new report if you still miss the item.',
  };
  Map<String, dynamic> toMap() => {
    ...VenueView.of(venue),
    'refCode': report.refCode,
    'status': report.status.name,
    'statusLabel': labels[report.status.index],
    'sentence': sentence,
    'filedAt': date(report.createdAt),
    'updatedAt': date(report.updatedAt),
    'possibleMatch': report.status == ReportStatus.possibleMatch,
    'closed': report.status == ReportStatus.closed,
    'steps': [
      for (final state in ReportStatus.values)
        {'label': labels[state.index], 'current': report.status == state},
    ],
  };
  Map<String, dynamic> toJson() => {
    'refCode': report.refCode,
    'status': report.status.name,
    'sentence': sentence,
    'filedAt': report.createdAt.toUtc().toIso8601String(),
    'updatedAt': report.updatedAt.toUtc().toIso8601String(),
    'venue': {
      'name': venue.name,
      'deskHours': venue.deskHours,
      'pickupInstructions': venue.pickupInstructions,
    },
  };
}
