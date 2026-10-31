import 'package:flutter/material.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/shared/widgets/taut_action_button.dart';

/// Banner merah "Sesi berbagi AKTIF" di atas halaman Lokasi.
///
/// Banner ini sengaja selalu di atas (sebelum tab Faskes/Teman) dan
/// punya tombol berhenti langsung — untuk keadaan darurat, pengguna
/// tidak boleh mencari-cari tombol berhenti di dalam menu.
/// Satu ketukan [onStop] langsung menghentikan sesi, tanpa dialog
/// konfirmasi kedua (pelajaran dari prototipe: dialog kedua membuat
/// pengguna mengira tombolnya tidak berfungsi).
class LocationSharingBanner extends StatelessWidget {
  const LocationSharingBanner({
    super.key,
    required this.recipientName,
    required this.remainingText,
    required this.onStop,
    required this.onViewPosition,
  });

  final String recipientName;
  final String remainingText;
  final VoidCallback onStop;
  final VoidCallback onViewPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.danger, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 12, color: AppTheme.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sesi berbagi AKTIF — $recipientName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Berakhir dalam $remainingText',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TautActionButton.danger(
            label: 'Berhenti Berbagi Sekarang',
            onPressed: onStop,
          ),
          const SizedBox(height: 8),
          TautActionButton.secondary(
            label: 'Lihat Posisi Saya',
            onPressed: onViewPosition,
          ),
        ],
      ),
    );
  }
}
