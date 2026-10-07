import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/localized_text.dart';
import '../services/location_service.dart';

class SelectedLocation {
  final LatLng coordinates;
  final double? accuracyMeters;
  const SelectedLocation(this.coordinates, {this.accuracyMeters});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool readOnly;
  const LocationPickerScreen({super.key, this.initialPosition, this.readOnly = false});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _map = MapController();
  SelectedLocation? _selected;
  bool _locating = false;
  String? _error;
  bool _openSettings = false;
  bool _tileFailed = false;
  int _tileGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selected = SelectedLocation(widget.initialPosition!);
    }
  }

  Future<void> _locate() async {
    setState(() { _locating = true; _error = null; _openSettings = false; });
    try {
      final position = await LocationService().currentPosition();
      if (!mounted) return;
      final coordinates = LatLng(position.latitude, position.longitude);
      setState(() => _selected = SelectedLocation(coordinates, accuracyMeters: position.accuracy));
      _map.move(coordinates, 17);
    } on LocationFailure catch (error) {
      if (mounted) setState(() { _error = error.message; _openSettings = error.openSettings; });
    } on TimeoutException {
      if (mounted) setState(() => _error = 'انتهت مهلة تحديد الموقع. حاول في مكان مفتوح أو اختر الموقع يدويًا.');
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحديد الموقع. تحقق من الإذن والاتصال أو اختر الموقع يدويًا.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  void dispose() { _map.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final point = _selected?.coordinates;
    return Scaffold(
      appBar: AppBar(title: const AppText('حدد موقع الخدمة')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          AppText(widget.readOnly ? 'موقع الخدمة' : 'اضغط على الخريطة لاختيار الموقع، أو استخدم موقعك الحالي.'),
          if (_error != null) ...[
            const SizedBox(height: 8),
            AppText(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_openSettings && !kIsWeb) TextButton(onPressed: Geolocator.openAppSettings,
              child: const AppText('فتح الإعدادات')),
          ],
        ])),
        if (_tileFailed) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          const Expanded(child: AppText('تعذر تحميل الخريطة. تحقق من الاتصال وأعد المحاولة.')),
          TextButton(onPressed: () => setState(() { _tileFailed = false; _tileGeneration++; }), child: const AppText('إعادة المحاولة')),
        ])),
        Expanded(child: FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: widget.initialPosition ?? const LatLng(24.7136, 46.6753),
            initialZoom: 13,
            onTap: widget.readOnly ? null : (_, coordinates) {
              if (_locating) return;
              setState(() { _selected = SelectedLocation(coordinates); _error = null; });
            },
          ),
          children: [
            TileLayer(key: ValueKey(_tileGeneration), urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sallih.customer',
              errorTileCallback: (_, error, stackTrace) {
                if (_tileFailed) return;
                _tileFailed = true;
                WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() {}); });
              }),
            if (point != null && _selected?.accuracyMeters != null) CircleLayer(circles: [CircleMarker(
              point: point, radius: _selected!.accuracyMeters!, useRadiusInMeter: true,
              color: Theme.of(context).colorScheme.primary.withAlpha(35),
              borderColor: Theme.of(context).colorScheme.primary, borderStrokeWidth: 1,
            )]),
            if (point != null) MarkerLayer(markers: [Marker(
              point: point, width: 48, height: 48,
              child: Icon(Icons.location_on, size: 48, color: Theme.of(context).colorScheme.primary),
            )]),
            SimpleAttributionWidget(source: const Text('OpenStreetMap contributors'),
              onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'))),
          ],
        )),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (point != null) Text('${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
              textAlign: TextAlign.center, textDirection: TextDirection.ltr),
            if (_selected?.accuracyMeters != null) AppText(
              'دقة الموقع: ${_selected!.accuracyMeters!.toStringAsFixed(0)} متر', textAlign: TextAlign.center),
            if ((_selected?.accuracyMeters ?? 0) > 100) const AppText('دقة الموقع منخفضة. تحقق من العلامة أو اختر الموقع يدويًا.'),
            if (point != null && _selected?.accuracyMeters == null)
              const AppText('موقع مختار يدويًا', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (!widget.readOnly) OutlinedButton.icon(onPressed: _locating ? null : _locate,
              icon: _locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location), label: const AppText('استخدام موقعي الحالي')),
            const SizedBox(height: 8),
            FilledButton(onPressed: point == null || _locating ? null : () => Navigator.pop(context, widget.readOnly ? null : _selected),
              child: AppText(widget.readOnly ? 'حسناً' : 'تأكيد الموقع')),
          ],
        ))),
      ]),
    );
  }
}
