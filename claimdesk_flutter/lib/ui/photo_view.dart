import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../data/photo_urls.dart';
import '../data/errors.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({
    super.key,
    required this.urls,
    required this.itemId,
    this.thumb = false,
    this.revision,
    this.onDenied,
  });
  final PhotoUrls urls;
  final UuidValue itemId;
  final bool thumb;
  final Object? revision;
  final VoidCallback? onDenied;
  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  String? _url;
  Object? _error;
  bool _loading = true;
  bool _retried = false;
  Timer? _expiry;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId ||
        oldWidget.revision != widget.revision ||
        oldWidget.thumb != widget.thumb) {
      _retried = false;
      _load();
    }
  }

  Future<void> _load({bool fresh = false}) async {
    final generation = ++_generation;
    _expiry?.cancel();
    try {
      final url = await widget.urls.get(
        widget.itemId,
        thumb: widget.thumb,
        fresh: fresh,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _url = url;
        _loading = false;
        _error = null;
      });
      if (url != null) {
        _expiry = Timer(const Duration(minutes: 9), () {
          _retried = false;
          _load(fresh: true);
        });
      }
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      if (e is NotAMemberException) widget.onDenied?.call();
    }
  }

  @override
  void dispose() {
    ++_generation;
    _expiry?.cancel();
    super.dispose();
  }

  Widget _placeholder(String label) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_outlined, size: widget.thumb ? 28 : 48),
        if (!widget.thumb) Text(label),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: _placeholder('Loading photo…'),
      );
    }
    if (_error != null) {
      return Tooltip(
        message: errorMessage(_error!),
        child: _placeholder('Photo unavailable'),
      );
    }
    if (_url == null) return _placeholder('No photo');
    return Image.network(
      _url!,
      fit: widget.thumb ? BoxFit.cover : BoxFit.contain,
      frameBuilder: (context, child, frame, synchronous) =>
          frame == null ? _placeholder('Loading photo…') : child,
      errorBuilder: (context, error, stack) {
        if (!_retried) {
          _retried = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _load(fresh: true);
          });
        }
        return _placeholder('Photo unavailable');
      },
    );
  }
}
