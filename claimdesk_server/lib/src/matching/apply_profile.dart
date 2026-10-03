/// Accumulates database round-trip durations without descriptions or secrets.
class ApplyProfile {
  int candidateQueries = 0, candidateMs = 0;
  int lockQueries = 0, lockMs = 0;
  int writeQueries = 0, writeMs = 0;
  int auditMs = 0, transactionMs = 0, eventsMs = 0;
  int applyAttempts = 0;

  Future<T> candidate<T>(Future<T> Function() query) async {
    candidateQueries++;
    final timer = Stopwatch()..start();
    try {
      return await query();
    } finally {
      candidateMs += timer.elapsedMilliseconds;
    }
  }

  Future<T> lock<T>(Future<T> Function() query) async {
    lockQueries++;
    final timer = Stopwatch()..start();
    try {
      return await query();
    } finally {
      lockMs += timer.elapsedMilliseconds;
    }
  }

  Future<T> write<T>(Future<T> Function() query) async {
    writeQueries++;
    final timer = Stopwatch()..start();
    try {
      return await query();
    } finally {
      writeMs += timer.elapsedMilliseconds;
    }
  }

  Future<T> audit<T>(Future<T> Function() query) async {
    final timer = Stopwatch()..start();
    try {
      return await query();
    } finally {
      auditMs += timer.elapsedMilliseconds;
    }
  }

  String line(String reference, {required bool draft}) {
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(reference)) {
      throw ArgumentError('Invalid report reference');
    }
    final retries = applyAttempts > 0 ? applyAttempts - 1 : 0;
    return 'Matching profile report=$reference '
        'candidateQueries=$candidateQueries candidateMs=$candidateMs '
        'lockQueries=$lockQueries lockMs=$lockMs '
        'writeQueries=$writeQueries writeMs=$writeMs auditMs=$auditMs '
        'serializationRetries=$retries transactionMs=$transactionMs '
        'eventsMs=$eventsMs draft=${draft ? 1 : 0}';
  }
}
