import 'package:claimdesk_server/src/services/photo_upload_relay.dart';
import 'package:test/test.dart';

void main() {
  test(
    'upload body is bounded across chunks and drained after exceeding the limit',
    () async {
      var drained = false;
      Stream<List<int>> body() async* {
        yield [1, 2, 3];
        yield [4, 5];
        yield [6];
        drained = true;
      }

      expect(await PhotoUploadRelay.readBounded(body(), 4), isNull);
      expect(drained, true);
      expect(
        await PhotoUploadRelay.readBounded(
          Stream.fromIterable([
            [1, 2],
            [3, 4],
          ]),
          4,
        ),
        [1, 2, 3, 4],
      );
    },
  );
}
