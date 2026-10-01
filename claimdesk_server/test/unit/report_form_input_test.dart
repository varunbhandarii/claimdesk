import 'package:claimdesk_server/src/web/public/report_form_input.dart';
import 'package:test/test.dart';

final form = <String, String>{
  'rawText': 'A black folding umbrella with a wooden handle',
  'categoryHint': 'umbrella',
  'colour_black': 'on',
  'contactEmail': ' OWNER@EXAMPLE.TEST ',
  'consent': 'on',
  'lostDate': '2026-09-30',
  'zoneId': 'zone',
  'ownerOnlyDetails': 'A small scratch inside',
};
ParsedForm parse(Map<String, String> f) => ReportFormInput.parse(
  f,
  zones: ['zone'],
  now: DateTime.utc(2026, 9, 30, 18),
  timezone: 'America/New_York',
);
void main() {
  test('valid form normalizes email and converts venue noon to UTC', () {
    final result = parse(form);
    expect(result.errors, isEmpty);
    expect(result.input!.contactEmail, 'owner@example.test');
    expect(result.input!.lostAt, DateTime.utc(2026, 9, 30, 16));
    expect(result.input!.colourHints, ['black']);
  });
  test(
    'description, dates, colours, email, consent and zone are validated',
    () {
      for (final entry in {
        'rawText': 'one',
        'lostDate': '2026-10-01',
        'contactEmail': 'wrong',
        'consent': '',
        'zoneId': 'another',
        'brandHint': 'x' * 61,
        'ownerOnlyDetails': 'x' * 301,
        'whereText': 'x' * 121,
        'ownerName': 'x' * 81,
      }.entries) {
        expect(
          parse({...form, entry.key: entry.value}).errors,
          contains(entry.key),
        );
      }
      expect(
        parse({...form, 'lostDate': '2026-01-01'}).errors,
        contains('lostDate'),
      );
      expect(
        parse({...form, 'lostDate': '2026-02-31'}).errors,
        contains('lostDate'),
      );
      expect(
        parse({
          ...form,
          'colour_white': 'on',
          'colour_red': 'on',
          'colour_blue': 'on',
        }).errors,
        contains('colours'),
      );
    },
  );
  test('unsure date uses report time and seven days of fuzz', () {
    final result = parse({...form, 'unsureDay': 'on', 'lostDate': ''});
    expect(result.input!.lostAtFuzzyDays, 7);
    expect(result.input!.lostAt, DateTime.utc(2026, 9, 30, 18));
  });
  test('controls are stripped, lengths bounded and honeypot flagged', () {
    expect(
      parse({
        ...form,
        'rawText': 'A black\u0000 umbrella with a wooden handle',
      }).input!.rawText,
      isNot(contains('\u0000')),
    );
    expect(parse({...form, 'rawText': 'x' * 401}).input, isNull);
    expect(
      parse({...form, 'website': 'https://spam.example'}).honeypot,
      isTrue,
    );
    expect(parse({...form, 'lostDate': '2026-07-02'}).errors, isEmpty);
  });
}
