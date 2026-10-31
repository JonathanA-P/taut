import 'package:flutter/material.dart';

/// Layar kosong untuk fitur yang belum dibangun.
///
/// Dipakai router untuk semua rute di luar Beranda selama Stage 01.
/// Pesannya jujur: fitur ini belum dibangun, bukan pura-pura jalan.
/// Begitu fitur aslinya selesai, rutenya diarahkan ke halaman asli
/// dan placeholder ini tidak lagi dipakai untuk rute itu.
class EmptyStatePlaceholder extends StatelessWidget {
  const EmptyStatePlaceholder({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
