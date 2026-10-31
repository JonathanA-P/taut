import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/taut_app_state.dart';
import '../../../../shared/widgets/taut_open_street_map.dart';

/// Interactive modal sheet displaying a specific friend's individual shared location.
class FriendLocationDetailSheet extends StatelessWidget {
  final IncomingSharingSession incoming;
  final VoidCallback onStopSharing;

  const FriendLocationDetailSheet({
    super.key,
    required this.incoming,
    required this.onStopSharing,
  });

  static Future<void> show(
    BuildContext context, {
    required IncomingSharingSession incoming,
    required VoidCallback onStopSharing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FriendLocationDetailSheet(
        incoming: incoming,
        onStopSharing: onStopSharing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();
    final friendPoint = LatLng(incoming.latitude, incoming.longitude);
    const userPoint = LatLng(-7.9723, 112.6318);

    final mapMarkers = [
      const TautMapMarker(
        point: userPoint,
        label: 'Posisi Saya',
        subtitle: 'Alun-Alun Tugu Malang (Akurasi GPS ±5m)',
        isUser: true,
      ),
      TautMapMarker(
        point: friendPoint,
        label: incoming.friendName,
        subtitle: incoming.subtitle,
        avatarText: incoming.friendName.isNotEmpty ? incoming.friendName[0] : '?',
        color: const Color(0xFF2E7D32),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DDD1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi ${incoming.friendName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pelacakan GPS real-time • Disetujui',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    tooltip: 'Tutup',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Interactive OpenStreetMap centered on this friend
              TautOpenStreetMap(
                initialCenter: friendPoint,
                initialZoom: 15.2,
                height: 240,
                markers: mapMarkers,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Peta interaktif OpenStreetMap • Posisi GPS teman',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detail Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDF0E9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05263D2F),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD6E7D2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            incoming.friendName.isNotEmpty
                                ? incoming.friendName[0]
                                : '?',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incoming.friendName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                incoming.subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Text(
                            incoming.remainingText(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFEDF0E9)),
                    _buildInfoRow(
                      icon: Icons.my_location_rounded,
                      label: 'Koordinat GPS',
                      value:
                          '${incoming.latitude.toStringAsFixed(4)}, ${incoming.longitude.toStringAsFixed(4)}',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Status Persetujuan',
                      value: 'Disetujui olehmu (Penerimaan aktif)',
                      valueColor: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Sisa Durasi Berbagi',
                      value: incoming.remainingText(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action CTAs
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          state.navigateTo('live');
                        },
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text(
                          'Buka di Peta Bersama',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onStopSharing();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF944838),
                          side: const BorderSide(color: Color(0xFFECCDC7)),
                          backgroundColor: const Color(0xFFFDF6F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Hentikan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.darkGreen,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
