import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/painting.dart';

class PhotoUrls {
  PhotoUrls(this.fetch, {this.fetchSignature});
  final Future<String?> Function(UuidValue id, bool thumb) fetch;
  final Future<String?> Function(UuidValue id)? fetchSignature;
  final _cache = <String, (String, DateTime)>{};
  final _pending = <String, Future<String?>>{};
  bool _disposed = false;
  Future<String?> signature(UuidValue id) {
    final key = 'sig/$id';
    final cached = _cache[key];
    if (cached != null && cached.$2.isAfter(DateTime.now())) {
      return Future.value(cached.$1);
    }
    return _pending.putIfAbsent(key, () async {
      try {
        final url = await fetchSignature?.call(id);
        if (!_disposed && url != null) {
          _cache[key] = (url, DateTime.now().add(const Duration(minutes: 9)));
        }
        return url;
      } finally {
        _pending.remove(key);
      }
    });
  }

  Future<String?> get(UuidValue id, {bool thumb = false, bool fresh = false}) {
    final key = '$id/$thumb';
    if (fresh) {
      final old = _cache.remove(key);
      if (old != null) NetworkImage(old.$1).evict();
    }
    final cached = _cache[key];
    if (cached != null && cached.$2.isAfter(DateTime.now())) {
      return Future.value(cached.$1);
    }
    return _pending.putIfAbsent(key, () async {
      try {
        final url = await fetch(id, thumb);
        if (!_disposed && url != null) {
          _cache[key] = (url, DateTime.now().add(const Duration(minutes: 9)));
        }
        return url;
      } finally {
        _pending.remove(key);
      }
    });
  }

  void invalidate(UuidValue id) {
    final signature = _cache.remove('sig/$id');
    if (signature != null) NetworkImage(signature.$1).evict();
    for (final thumb in [false, true]) {
      final old = _cache.remove('$id/$thumb');
      if (old != null) NetworkImage(old.$1).evict();
    }
  }

  void dispose() {
    _disposed = true;
    for (final cached in _cache.values) {
      NetworkImage(cached.$1).evict();
    }
    _cache.clear();
    _pending.clear();
  }
}
