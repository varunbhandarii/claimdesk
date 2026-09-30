import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/item_form.dart';

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
    final camera =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Log a found item')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Give it a place.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start with a photo. The desk will fill in the details while you carry on.',
                ),
                const SizedBox(height: 24),
                if (_bytes != null) ...[
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_bytes!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (camera)
                      FilledButton.icon(
                        onPressed: _saving || _picking
                            ? null
                            : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(_bytes == null ? 'Take photo' : 'Retake'),
                      ),
                    OutlinedButton.icon(
                      onPressed: _saving || _picking
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose photo'),
                    ),
                    if (_bytes != null)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() {
                                _bytes = null;
                                _ticket = null;
                                _uploaded = false;
                              }),
                        child: const Text('Remove photo'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Typed details are used if photo captioning is unavailable. Saving without a photo is also fine.',
                ),
                const SizedBox(height: 24),
                ItemForm(
                  controller: _form,
                  zones: session.zones,
                  enabled: !_saving,
                  onChanged: () => setState(() {}),
                ),
                if (session.zones.isEmpty) ...[
                  const Text(
                    'Zones are unavailable. Check the connection and retry.',
                  ),
                  TextButton(
                    onPressed: session.refreshItems,
                    child: const Text('Reload zones'),
                  ),
                ],
                const SizedBox(height: 24),
                if (_progress != null) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(_progress!),
                  const SizedBox(height: 16),
                ],
                FilledButton(
                  onPressed: _saving || _picking || _form.zoneId == null
                      ? null
                      : _save,
                  child: Text(_saving ? 'Saving…' : 'Save item'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
