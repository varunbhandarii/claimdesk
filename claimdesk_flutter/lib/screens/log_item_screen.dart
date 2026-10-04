import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/item_form.dart';

const _bandFloors = {
  ValueBand.under20: 0,
  ValueBand.from20to99: 2000,
  ValueBand.from100to499: 10000,
  ValueBand.from500to4999: 50000,
  ValueBand.over5000: 500000,
};

/// Which value bands start the venue's police hand-off timer.
String? handoffHint(Venue venue) {
  final days = venue.policeHandoffDays;
  final first = ValueBand.values
      .where((band) => _bandFloors[band]! >= venue.policeHandoffThresholdCents)
      .firstOrNull;
  if (first == null) return null;
  if (first == ValueBand.under20) {
    return 'Every item starts the $days-day police hand-off timer.';
  }
  return first == ValueBand.over5000
      ? '${valueBandLabel(first)} starts the $days-day police hand-off timer.'
      : '${valueBandLabel(first)} and above start the $days-day police hand-off timer.';
}

class LogItemScreen extends StatefulWidget {
  const LogItemScreen({super.key});
  @override
  State<LogItemScreen> createState() => _LogItemScreenState();
}

class _LogItemScreenState extends State<LogItemScreen> {
  final _form = ItemFormController();
  final _picker = ImagePicker();
  Uint8List? _bytes;
  PhotoUploadTicket? _ticket;
  String _contentType = 'image/jpeg';
  String? _progress;
  bool _saving = false;
  bool _started = false;
  bool _picking = false;
  bool _uploaded = false;
  int _createRetries = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _restore();
    }
  }

  Future<void> _restore() async {
    final session = VenueScope.of(context);
    await runGuarded(context, () async {
      final preferences = await SharedPreferences.getInstance();
      final zone = preferences.getString('zone_${session.venue.id}');
      if (mounted &&
          _form.zoneId == null &&
          zone != null &&
          session.zones.any((z) => z.id.toString() == zone)) {
        setState(() => _form.zoneId = UuidValue.fromString(zone));
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final lost = await _picker.retrieveLostData();
        if (lost.exception != null) throw lost.exception!;
        if (lost.files?.isNotEmpty == true) await _usePhoto(lost.files!.first);
      }
    }, onDenied: session.onDenied);
  }

  Future<void> _usePhoto(XFile photo) async {
    final bytes = await photo.readAsBytes();
    final type = bytes.length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8
        ? 'image/jpeg'
        : bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50
        ? 'image/png'
        : bytes.length >= 12 &&
              String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
              String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP'
        ? 'image/webp'
        : null;
    if (type == null) throw Exception('Choose a JPEG, PNG or WebP photo.');
    if (bytes.length > 15 * 1024 * 1024) {
      throw Exception('Choose a photo smaller than 15 MB.');
    }
    if (mounted) {
      setState(() {
        _bytes = bytes;
        _contentType = type;
        _ticket = null;
        _uploaded = false;
        _createRetries = 0;
      });
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _picking = true);
    await runGuarded(context, () async {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (photo != null) await _usePhoto(photo);
    });
    if (mounted) setState(() => _picking = false);
  }

  Future<void> _save() async {
    final session = VenueScope.of(context);
    setState(() {
      _saving = true;
      _progress = _bytes == null ? 'Saving item…' : '1 of 3 · Uploading photo…';
    });
    final item = await runGuarded(context, () async {
      if (_bytes != null) {
        if (_ticket != null &&
            (!_ticket!.expiresAt.isAfter(DateTime.now()) ||
                _createRetries > 1)) {
          throw Exception(
            'The upload ticket expired or was already retried. Choose the photo again, then save.',
          );
        }
        _ticket ??= await session.client.item.requestPhotoUpload(
          session.venue.id!,
          _contentType,
        );
        if (!_uploaded) {
          final ok = await FileUploader(
            _ticket!.uploadDescription,
          ).uploadByteData(ByteData.sublistView(_bytes!));
          if (!ok) {
            _ticket = null;
            throw Exception(
              'Upload failed. Check the connection and try again.',
            );
          }
          _uploaded = true;
        }
      }
      if (mounted) setState(() => _progress = '2 of 3 · Saving item…');
      FoundItem? created;
      if (_createRetries > 0 && _ticket != null) {
        final items = await session.client.item.listItems(
          session.venue.id!,
          ItemFilter(),
        );
        created = items.where((item) => item.id == _ticket!.itemId).firstOrNull;
      }
      created ??= await session.client.item.createItem(
        session.venue.id!,
        _form.buildInput(ticket: _ticket),
      );
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(
          'zone_${session.venue.id}',
          _form.zoneId.toString(),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Item saved. The last zone could not be remembered.',
              ),
            ),
          );
        }
      }
      return created;
    }, onDenied: session.onDenied);
    if (!mounted) return;
    if (item != null) {
      setState(() => _progress = '3 of 3 · Done');
      Navigator.pop(context, item);
    } else {
      if (_uploaded) _createRetries++;
      setState(() {
        _saving = false;
        _progress = null;
      });
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    final c = context.desk;
    final camera =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final busy = _saving || _picking;
    final note =
        _progress ??
        (_form.zoneId == null
            ? 'Choose where it was found to save.'
            : _bytes == null
            ? 'You can save without a photo and add details later.'
            : 'Captioning usually finishes in under 15 seconds.');
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            onPressed: _saving ? null : () => Navigator.maybePop(context),
            icon: const Icon(Icons.close),
          ),
          title: const Text('Log a found item'),
        ),
        body: LayoutBuilder(
          builder: (context, box) => ListView(
            padding: EdgeInsets.fromLTRB(
              box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
              4,
              box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
              32,
            ),
            children: [
              Text('Give it a place.', style: context.type.displayAt(34)),
              const SizedBox(height: 8),
              Text(
                'Start with a photo. The desk fills in the details while you carry on.',
                style: TextStyle(color: c.ink2),
              ),
              const SizedBox(height: 24),
              _PhotoArea(
                bytes: _bytes,
                camera: camera,
                enabled: !busy,
                onCamera: () => _pick(ImageSource.camera),
                onGallery: () => _pick(ImageSource.gallery),
                onRemove: () => setState(() {
                  _bytes = null;
                  _ticket = null;
                  _uploaded = false;
                }),
              ),
              const SizedBox(height: 10),
              Text(
                'Typed details are used if photo captioning is unavailable. Saving without a photo is also fine.',
                style: context.type.small.copyWith(color: c.ink3),
              ),
              const SizedBox(height: 24),
              if (session.zones.isEmpty) ...[
                NoteStrip(
                  icon: Icons.wifi_off,
                  tone: DiscTone.warn,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Zones are unavailable. Check the connection and retry.',
                        ),
                      ),
                      TextButton(
                        onPressed: session.refreshItems,
                        child: const Text('Reload zones'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ItemForm(
                controller: _form,
                zones: session.zones,
                enabled: !_saving,
                handoffHint: handoffHint(session.venue),
                onChanged: () => setState(() {}),
              ),
            ],
          ),
        ),
        bottomNavigationBar: StickyBar(
          note: note,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_progress != null) ...[
                const LinearProgressIndicator(minHeight: 3),
                const SizedBox(height: 10),
              ],
              FilledButton(
                style: bigButtonStyle(context),
                onPressed: busy || _form.zoneId == null ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoArea extends StatelessWidget {
  const _PhotoArea({
    required this.bytes,
    required this.camera,
    required this.enabled,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });
  final Uint8List? bytes;
  final bool camera, enabled;
  final VoidCallback onCamera, onGallery, onRemove;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: c.surface2,
                child: Image.memory(
                  bytes!,
                  fit: BoxFit.contain,
                  semanticLabel: 'Chosen photo',
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (camera)
                      FilledButton.tonalIcon(
                        style: _overlay(c),
                        onPressed: enabled ? onCamera : null,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Retake'),
                      ),
                    FilledButton.tonalIcon(
                      style: _overlay(c),
                      onPressed: enabled ? onGallery : null,
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('Choose another'),
                    ),
                    FilledButton.tonalIcon(
                      style: _overlay(c),
                      onPressed: enabled ? onRemove : null,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Remove photo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CustomPaint(
      foregroundPainter: _DashedFrame(c.lineStrong, 20),
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: c.tag, shape: BoxShape.circle),
              child: Icon(
                Icons.photo_camera_outlined,
                size: 28,
                color: c.tagOn,
              ),
            ),
            const SizedBox(height: 14),
            if (camera) ...[
              FilledButton(
                onPressed: enabled ? onCamera : null,
                child: const Text('Take photo'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: enabled ? onGallery : null,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text('Choose from gallery'),
              ),
            ] else
              FilledButton.icon(
                onPressed: enabled ? onGallery : null,
                icon: const Icon(Icons.image_outlined, size: 20),
                label: const Text('Choose photo'),
              ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _overlay(DeskColors c) => FilledButton.styleFrom(
    backgroundColor: c.surface.withValues(alpha: .94),
    foregroundColor: c.ink,
    minimumSize: const Size(44, 40),
    padding: const EdgeInsets.symmetric(horizontal: 12),
  );
}

class _DashedFrame extends CustomPainter {
  _DashedFrame(this.colour, this.radius);
  final Color colour;
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += 13) {
        canvas.drawPath(metric.extractPath(at, at + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedFrame old) => old.colour != colour;
}
