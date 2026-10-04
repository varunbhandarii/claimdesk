import 'package:timezone/timezone.dart' as tz;
import '../../generated/protocol.dart';
import '../../policy/taxonomy.dart';
import 'public_lang.dart';
import 'public_strings.dart';
import 'report_form_input.dart';

class VenueView {
  static Map<String, dynamic> of(
    Venue venue, {
    PublicLang lang = PublicLang.en,
  }) {
    final t = PublicStrings.of(lang);
    return {
      'name': venue.name,
      'slug': venue.slug,
      'deskHours': venue.deskHours ?? t['defaultHours'],
      'pickupInstructions': venue.pickupInstructions ?? t['defaultPickup'],
    };
  }
}

class FormView {
  static Map<String, dynamic> of(
    Venue venue,
    List<Zone> zones, {
    Map<String, String> fields = const {},
    Map<String, String> errors = const {},
    PublicLang lang = PublicLang.en,
  }) {
    final groups = <String, String>{};
    for (final entry in Taxonomy.groups.entries) {
      groups.putIfAbsent(entry.value, () => entry.key);
    }
    groups['Clothing'] = 'clothing_other';
    groups['Toys, gifts & miscellaneous'] = 'other';
    return {
      ...VenueView.of(venue, lang: lang),
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
              'label': PublicStrings.group(e.key, lang),
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
              'name': swatchName(c, lang: lang),
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

const _monthsEs = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sept',
  'oct',
  'nov',
  'dic',
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
String swatchName(String colour, {PublicLang lang = PublicLang.en}) =>
    lang == PublicLang.es
    ? PublicStrings.swatchesEs[colour] ?? colour
    : switch (colour) {
        'multicolour' => 'Multi',
        'transparent' => 'Clear',
        _ => colour[0].toUpperCase() + colour.substring(1),
      };

/// "Sep 30" ("30 sept" in Spanish) in the given venue-local time, with the
/// year when it differs from [now]'s.
String shortDay(
  DateTime local, {
  DateTime? now,
  PublicLang lang = PublicLang.en,
}) {
  final sameYear = now == null || now.year == local.year;
  if (lang == PublicLang.es) {
    final day = '${local.day} ${_monthsEs[local.month - 1]}';
    return sameYear ? day : '$day ${local.year}';
  }
  final day = '${_months[local.month - 1]} ${local.day}';
  return sameYear ? day : '$day, ${local.year}';
}

class TicketView {
  static String idTypeLabel(String value, {PublicLang lang = PublicLang.en}) {
    final t = PublicStrings.of(lang);
    return switch (value) {
      'drivers_licence' => t['idDriversLicence']!,
      'passport' => t['idPassport']!,
      'student_id' => t['idStudent']!,
      'other_government_id' => t['idOtherGovernment']!,
      _ => t['idNone']!,
    };
  }

  TicketView(this.report, this.venue, {this.lang = PublicLang.en});
  final LostReport report;
  final Venue venue;
  final PublicLang lang;

  /// Status labels in [ReportStatus] order.
  static List<String> labelsFor(PublicLang lang) {
    final t = PublicStrings.of(lang);
    return [
      for (final status in ReportStatus.values)
        t['status${_capitalised(status.name)}']!,
    ];
  }

  static String _capitalised(String name) =>
      name[0].toUpperCase() + name.substring(1);

  List<String> get labels => labelsFor(lang);

  static const flow = [
    ReportStatus.received,
    ReportStatus.searching,
    ReportStatus.possibleMatch,
    ReportStatus.readyForPickup,
    ReportStatus.returned,
  ];

  tz.TZDateTime local(DateTime value) =>
      tz.TZDateTime.from(value, ReportFormInput.location(venue.timezone));

  /// "Sep 30, 2026, 12:00 PM EDT" ("30 sept 2026, 12:00 p. m. EDT" in
  /// Spanish) in the venue's timezone.
  String date(DateTime value) {
    final at = local(value);
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final minute = at.minute.toString().padLeft(2, '0');
    if (lang == PublicLang.es) {
      return '${shortDay(at, lang: lang)} ${at.year}, $hour:$minute ${at.hour < 12 ? 'a. m.' : 'p. m.'} ${at.timeZoneName}';
    }
    return '${shortDay(at)}, ${at.year}, $hour:$minute ${at.hour < 12 ? 'AM' : 'PM'} ${at.timeZoneName}';
  }

  /// "OCT 04 2026" ("04 OCT 2026" in Spanish) for the returned stamp.
  String stampDate(DateTime value) {
    final at = local(value);
    final day = at.day.toString().padLeft(2, '0');
    return lang == PublicLang.es
        ? '$day ${_monthsEs[at.month - 1].toUpperCase()} ${at.year}'
        : '${_months[at.month - 1].toUpperCase()} $day ${at.year}';
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

  String get sentence {
    final t = PublicStrings.of(lang);
    final text = t['sentence${_capitalised(report.status.name)}']!;
    return switch (report.status) {
      ReportStatus.returned => PublicStrings.fill(text, {
        'date': date(report.updatedAt),
      }),
      ReportStatus.closed => PublicStrings.fill(text, {
        'date': date(report.closedAt ?? report.updatedAt),
      }),
      _ => text,
    };
  }

  Map<String, dynamic> toMap() {
    final t = PublicStrings.of(lang);
    final step = flow.indexOf(report.status) + 1;
    return {
      ...VenueView.of(venue, lang: lang),
      'refCode': report.refCode,
      'status': report.status.name,
      'statusLabel': labels[report.status.index],
      'sentence': sentence,
      'filedAt': date(report.createdAt),
      'updatedAt': date(report.updatedAt),
      'filedLine': PublicStrings.fill(t['filedLine']!, {
        'filed': date(report.createdAt),
        'updated': date(report.updatedAt),
      }),
      'possibleMatch': report.status == ReportStatus.possibleMatch,
      'ready': report.status == ReportStatus.readyForPickup,
      'returned': report.status == ReportStatus.returned,
      'closed': report.status == ReportStatus.closed,
      'compact': {
        ReportStatus.possibleMatch,
        ReportStatus.readyForPickup,
      }.contains(report.status),
      'stepNumber': step,
      'stepCount': flow.length,
      'stepText': PublicStrings.fill(t['stepOf']!, {
        'n': step,
        'count': flow.length,
      }),
      'segments': [
        for (var i = 0; i < flow.length; i++)
          {'on': i <= flow.indexOf(report.status)},
      ],
      'steps': steps,
    };
  }

  /// The status interface stays English whatever language the page is in.
  Map<String, dynamic> toJson() {
    final english = lang == PublicLang.en ? this : TicketView(report, venue);
    return {
      'refCode': report.refCode,
      'status': report.status.name,
      'sentence': english.sentence,
      'filedAt': report.createdAt.toUtc().toIso8601String(),
      'updatedAt': report.updatedAt.toUtc().toIso8601String(),
      'venue': {
        'name': venue.name,
        'deskHours': venue.deskHours,
        'pickupInstructions': venue.pickupInstructions,
      },
    };
  }
}
