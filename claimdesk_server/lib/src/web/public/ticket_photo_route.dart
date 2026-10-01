import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../services/public_intake_service.dart';
import 'public_page.dart';

class TicketPhotoRoute extends PublicRoute {
  TicketPhotoRoute() : super(methods: {Method.get});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final report = await PublicIntakeService().findByToken(
      session,
      request.pathParameters.raw[#token] ?? '',
    );
    if (report?.status != ReportStatus.readyForPickup) {
      return PublicPage.notFound();
    }
    final match = await ItemMatch.db.findFirstRow(
      session,
      where: (t) =>
          t.reportId.equals(report!.id!) &
          t.venueId.equals(report.venueId) &
          t.state.equals(MatchState.confirmed),
    );
    final item = match == null
        ? null
        : await FoundItem.db.findById(session, match.itemId);
    final path = item?.thumbPath;
    if (item == null ||
        item.venueId != report!.venueId ||
        item.restricted ||
        item.status != ItemStatus.matched ||
        path == null ||
        !await session.storage.fileExists(storageId: 'private', path: path)) {
      return PublicPage.notFound();
    }
    final data = await session.storage.retrieveFile(
      storageId: 'private',
      path: path,
    );
    return Response(
      200,
      body: Body.fromData(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        mimeType: const MimeType('image', 'jpeg'),
      ),
      headers: PublicPage.headers(noStore: true),
    );
  }
}
