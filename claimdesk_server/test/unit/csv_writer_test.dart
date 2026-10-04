import 'dart:convert';
import 'package:claimdesk_server/src/services/csv_export.dart';
import 'package:test/test.dart';

void main() {
  test('CSV quotes commas, quotes and newlines with a BOM and CRLF', () {
    final bytes = CsvWriter.bytes(
      ['name', 'note'],
      [
        ['A, B', 'a "quote"\nnext'],
        [null, 'normal'],
      ],
    );
    expect(bytes.buffer.asUint8List().take(3), [0xef, 0xbb, 0xbf]);
    expect(
      utf8.decode(bytes.buffer.asUint8List()),
      'name,note\r\n"A, B","a ""quote""\nnext"\r\n,normal\r\n',
    );
  });
  test(
    'spreadsheet formula text stays text and UTC dates remain unambiguous',
    () {
      expect(
        CsvWriter.field('=HYPERLINK("example")'),
        '"\'=HYPERLINK(""example"")"',
      );
      expect(CsvWriter.field('-cmd'), "'-cmd");
      expect(CsvWriter.field(-3), '-3');
      expect(
        CsvWriter.field(DateTime.utc(2026, 10, 3)),
        '2026-10-03T00:00:00.000Z',
      );
    },
  );
}
