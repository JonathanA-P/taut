import 'package:flutter/material.dart';
import 'package:taut/core/theme/app_theme.dart';

/// Kartu penjelasan SEBELUM izin perangkat diminta.
///
/// Aturan TAUT: jangan pernah meminta izin (lokasi/kamera/mikrofon)
/// tanpa menjelaskan dulu untuk apa izin itu, apa yang terjadi kalau
/// ditolak, dan bahwa pengguna bisa mengubahnya kapan saja di
/// Pengaturan. Kartu ini tampil di atas tombol "Izinkan".
class PermissionExplanationCard extends StatelessWidget {
  const PermissionExplanationCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
