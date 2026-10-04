import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../policy/taxonomy.dart';
import 'public_lang.dart';
import 'public_strings.dart';

class ReportFormInput {
  ReportFormInput({
    required this.rawText,
    required this.colourHints,
    required this.contactEmail,
    required this.lostAt,
    required this.lostAtFuzzyDays,
    this.categoryHint,
    this.brandHint,
    this.zoneId,
    this.whereText,
    this.ownerOnlyDetails,
    this.ownerName,
  });
  final String rawText, contactEmail;
  final List<String> colourHints;
  final String? categoryHint,
      brandHint,
      zoneId,
      whereText,
      ownerOnlyDetails,
      ownerName;
  final DateTime lostAt;
  final int lostAtFuzzyDays;
  static bool _tzReady = false;
  static tz.Location location(String timezone) {
    if (!_tzReady) {
      tz_data.initializeTimeZones();
      _tzReady = true;
    }
    return tz.getLocation(timezone);
  }

  static ParsedForm parse(
    Map<String, String> form, {
    required Iterable<String> zones,
    required DateTime now,
    required String timezone,
    PublicLang lang = PublicLang.en,
  }) {
    final t = PublicStrings.of(lang);
    final errors = <String, String>{};
    String field(String key, int max) {
      final value = (form[key] ?? '')
          .replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '')
          .trim();
      if (value.length > max) {
        errors[key] = PublicStrings.fill(t['errMax']!, {'max': max});
      }
      return value.length > max ? value.substring(0, max) : value;
    }

    final text = field('rawText', 400);
    if (text.length < 20 ||
        text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length < 3) {
      errors['rawText'] = t['errDescribe']!;
    }
    final category = field('categoryHint', 60);
    if (category.isNotEmpty && !Taxonomy.groups.containsKey(category)) {
      errors['categoryHint'] = t['errCategory']!;
    }
    final colours = [
      for (final c in Taxonomy.colours)
        if (form['colour_$c'] == 'on') c,
    ];
    if (colours.length > 3) errors['colours'] = t['errColours']!;
    final brand = field('brandHint', 60),
        zone = field('zoneId', 40),
        where = field('whereText', 120);
    if (zone.isNotEmpty && !zones.contains(zone)) {
      errors['zoneId'] = t['errZone']!;
    }
    final details = field('ownerOnlyDetails', 300),
        name = field('ownerName', 80);
    final email = field('contactEmail', 254).toLowerCase();
    if (!RegExp(r'^[^\s@<>]+@[^\s@<>]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      errors['contactEmail'] = t['errEmail']!;
    }
    if (form['consent'] != 'on') {
      errors['consent'] = t['errConsent']!;
    }
    final unsure = form['unsureDay'] == 'on';
    var lostAt = now.toUtc();
    if (!unsure) {
      final date = field('lostDate', 10);
      final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date);
      if (match == null) {
        errors['lostDate'] = t['errDateMissing']!;
      } else {
        final y = int.parse(match[1]!),
            m = int.parse(match[2]!),
            d = int.parse(match[3]!);
        final calendar = DateTime.utc(y, m, d);
        final localNow = tz.TZDateTime.from(now, location(timezone));
        final today = DateTime.utc(localNow.year, localNow.month, localNow.day);
        if (calendar.year != y ||
            calendar.month != m ||
            calendar.day != d ||
            calendar.isAfter(today) ||
            calendar.isBefore(today.subtract(const Duration(days: 90)))) {
          errors['lostDate'] = t['errDateRange']!;
        } else {
          lostAt = tz.TZDateTime(location(timezone), y, m, d, 12).toUtc();
        }
      }
    }
    String? optional(String value) => value.isEmpty ? null : value;
    return ParsedForm(
      errors: errors,
      honeypot: (form['website'] ?? '').trim().isNotEmpty,
      input: errors.isEmpty
          ? ReportFormInput(
              rawText: text,
              categoryHint: optional(category),
              colourHints: colours,
              brandHint: optional(brand),
              zoneId: optional(zone),
              whereText: optional(where),
              lostAt: lostAt,
              lostAtFuzzyDays: unsure ? 7 : 0,
              ownerOnlyDetails: optional(details),
              contactEmail: email,
              ownerName: optional(name),
            )
          : null,
    );
  }
}

class ParsedForm {
  ParsedForm({required this.errors, required this.honeypot, this.input});
  final ReportFormInput? input;
  final Map<String, String> errors;
  final bool honeypot;
}
