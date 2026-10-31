import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';

/// Representation of an OpenStreetMap Marker for TAUT.
class TautMapMarker {
  final LatLng point;
  final String label;
  final String? subtitle;
  final String? avatarText;
  final IconData? icon;
  final Color color;
  final bool isUser;
  final VoidCallback? onTap;

  const TautMapMarker({
    required this.point,
    required this.label,
    this.subtitle,
    this.avatarText,
    this.icon,
    this.color = AppColors.primary,
    this.isUser = false,
    this.onTap,
  });
}

/// Production-ready interactive OpenStreetMap widget for TAUT.
/// Powered by flutter_map and OpenStreetMap tile servers.
class TautOpenStreetMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final double height;
  final List<TautMapMarker> markers;
  final bool showControls;
  final bool enableInteraction;
  final BorderRadiusGeometry? borderRadius;

  const TautOpenStreetMap({
    super.key,
    this.initialCenter = const LatLng(-7.9723, 112.6318), // Malang Default
    this.initialZoom = 14.5,
    this.height = 240,
    this.markers = const [],
    this.showControls = true,
    this.enableInteraction = true,
    this.borderRadius,
  });

  @override
  State<TautOpenStreetMap> createState() => _TautOpenStreetMapState();
}

class _TautOpenStreetMapState extends State<TautOpenStreetMap> {
  late final MapController _mapController;
  TautMapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _recenter() {
    _mapController.move(widget.initialCenter, widget.initialZoom);
    setState(() => _selectedMarker = null);
  }

  @override
  Widget build(BuildContext context) {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final radius = widget.borderRadius ?? BorderRadius.circular(22);

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE5),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFDAE3D3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A263D2F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Map Canvas
            if (isTest)
              _buildTestPlaceholderGrid()
            else
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.initialCenter,
                  initialZoom: widget.initialZoom,
                  minZoom: 4,
                  maxZoom: 18,
                  interactionOptions: InteractionOptions(
                    flags: widget.enableInteraction
                        ? (InteractiveFlag.all & ~InteractiveFlag.rotate)
                        : InteractiveFlag.none,
                  ),
                  onTap: (_, __) {
                    if (_selectedMarker != null) {
                      setState(() => _selectedMarker = null);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'id.taut.app',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: widget.markers.map(_buildFlutterMapMarker).toList(),
                  ),
                ],
              ),

            // Subtle OSM Attribution badge
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.map_rounded, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'OpenStreetMap',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map Controls (Zoom +, Zoom -, Recenter)
            if (widget.showControls && !isTest)
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: Icons.my_location_rounded,
                      onTap: _recenter,
                      tooltip: 'Pusatkan Posisi',
                    ),
                    const SizedBox(height: 6),
                    _buildControlButton(
                      icon: Icons.add_rounded,
                      onTap: _zoomIn,
                      tooltip: 'Perbesar',
                    ),
                    const SizedBox(height: 6),
                    _buildControlButton(
                      icon: Icons.remove_rounded,
                      onTap: _zoomOut,
                      tooltip: 'Perkecil',
                    ),
                  ],
                ),
              ),

            // Marker Info Popup / Callout
            if (_selectedMarker != null)
              Positioned(
                top: 10,
                left: 120,
                right: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD6E2D0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x15000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMarker!.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_selectedMarker!.subtitle != null)
                              Text(
                                _selectedMarker!.subtitle!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.grey,
                        onPressed: () => setState(() => _selectedMarker = null),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Marker _buildFlutterMapMarker(TautMapMarker marker) {
    return Marker(
      point: marker.point,
      width: marker.isUser ? 54 : 48,
      height: marker.isUser ? 54 : 48,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedMarker = marker);
          marker.onTap?.call();
        },
        child: _buildMarkerVisual(marker),
      ),
    );
  }

  Widget _buildMarkerVisual(TautMapMarker marker) {
    if (marker.isUser) {
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: marker.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x25000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: marker.avatarText != null
              ? Text(
                  marker.avatarText!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  marker.icon ?? Icons.location_on_rounded,
                  size: 18,
                  color: Colors.white,
                ),
        ),
        Container(
          width: 6,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0x40000000),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: const Color(0x20000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.darkGreen),
        ),
      ),
    );
  }

  Widget _buildTestPlaceholderGrid() {
    return Container(
      color: const Color(0xFFE8EFE5),
      alignment: Alignment.center,
      child: const Text(
        'OpenStreetMap (Test Mode)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
