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
              'name': swatchName(c),
              'tick': _lightSwatches.contains(c) ? 'tick-dark' : 'tick-light',
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

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Swatches light enough to need a dark check mark.
const _lightSwatches = {
  'white',
  'silver',
  'gold',
  'yellow',
  'orange',
  'pink',
  'beige',
  'transparent',
};

/// Short visible name under a colour swatch.
String swatchName(String colour) => switch (colour) {
  'multicolour' => 'Multi',
  'transparent' => 'Clear',
  _ => colour[0].toUpperCase() + colour.substring(1),
};

/// "Sep 30" in the given venue-local time, with the year when it differs
/// from [now]'s.
String shortDay(DateTime local, {DateTime? now}) {
  final day = '${_months[local.month - 1]} ${local.day}';
  return now == null || now.year == local.year ? day : '$day, ${local.year}';
}

class TicketView {
  static String idTypeLabel(String value) => switch (value) {
    'drivers_licence' => "Driver's licence",
    'passport' => 'Passport',
    'student_id' => 'Student ID',
    'other_government_id' => 'Other government ID',
    _ => 'None',
  };
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
  static const flow = [
    ReportStatus.received,
    ReportStatus.searching,
    ReportStatus.possibleMatch,
    ReportStatus.readyForPickup,
    ReportStatus.returned,
  ];

  tz.TZDateTime local(DateTime value) =>
      tz.TZDateTime.from(value, ReportFormInput.location(venue.timezone));

  /// "Sep 30, 2026, 12:00 PM EDT" in the venue's timezone.
  String date(DateTime value) {
    final at = local(value);
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    return '${shortDay(at)}, ${at.year}, $hour:${at.minute.toString().padLeft(2, '0')} ${at.hour < 12 ? 'AM' : 'PM'} ${at.timeZoneName}';
  }

  /// "OCT 04 2026" for the returned stamp.
  String stampDate(DateTime value) {
    final at = local(value);
    return '${_months[at.month - 1].toUpperCase()} ${at.day.toString().padLeft(2, '0')} ${at.year}';
  }

  /// Progress through the claim, one entry per step. A closed report shows
  /// only that it was received and then closed.
  List<Map<String, dynamic>> get steps {
    if (report.status == ReportStatus.closed) {
      return [
        {
          'label': labels[ReportStatus.received.index],
          'done': true,
          'current': false,
          'next': false,
          'when': date(report.createdAt),
        },
        {
          'label': labels[ReportStatus.closed.index],
          'done': false,
          'current': true,
          'next': false,
          'when': null,
        },
      ];
    }
    final at = flow.indexOf(report.status);
    return [
      for (var i = 0; i < flow.length; i++)
        {
          'label': labels[flow[i].index],
          'done': i < at,
          'current': i == at,
          'next': i > at,
          'when': i == 0 && at > 0 ? date(report.createdAt) : null,
        },
    ];
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
    'ready': report.status == ReportStatus.readyForPickup,
    'returned': report.status == ReportStatus.returned,
    'closed': report.status == ReportStatus.closed,
    'compact': {
      ReportStatus.possibleMatch,
      ReportStatus.readyForPickup,
    }.contains(report.status),
    'stepNumber': flow.indexOf(report.status) + 1,
    'stepCount': flow.length,
    'segments': [
      for (var i = 0; i < flow.length; i++)
        {'on': i <= flow.indexOf(report.status)},
    ],
    'steps': steps,
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
