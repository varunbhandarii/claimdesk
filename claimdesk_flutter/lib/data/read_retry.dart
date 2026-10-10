import 'package:claimdesk_client/claimdesk_client.dart';

/// Endpoint methods that only read, so a failed call can safely be sent again.
const readMethods = <String, Set<String>>{
  'desk': {'summary'},
  'item': {
    'getItem',
    'findByRefCode',
    'listItems',
    'searchItems',
    'photoUrl',
    'captionRuns',
    'history',
    'custody',
    'tagLink',
  },
  'match': {'answers', 'inbox', 'forReport', 'forItem'},
  'release': {'releaseRecord', 'signatureUrl'},
  'report': {'history', 'listReports', 'getReport', 'findByRefCode'},
  'venue': {'myMemberships', 'getVenue', 'zones', 'posterLink'},
};

bool isReadMethod(String endpoint, String method) =>
    readMethods[endpoint]?.contains(method) ?? false;

/// Sends a read again after a network failure. When the phone comes back from
/// the background, the first calls often go out on connections the system
/// closed while the app was paused; a second attempt opens a fresh one.
/// Writes are never repeated.
Future<T> retryReads<T>(
  String endpoint,
  String method,
  Future<T> Function() call, {
  List<Duration> delays = const [
    Duration(milliseconds: 600),
    Duration(milliseconds: 1500),
  ],
}) async {
  if (!isReadMethod(endpoint, method)) return call();
  for (var attempt = 0; ; attempt++) {
    try {
      return await call();
    } on ServerpodClientNetworkException {
      if (attempt >= delays.length) rethrow;
      await Future<void>.delayed(delays[attempt]);
    }
  }
}
