import 'package:flutter/material.dart';
import 'package:taut/core/theme/app_theme.dart';

/// Badge status kecil: teks + titik warna, selalu berpasangan.
///
/// Aturan aksesibilitas TAUT: status tidak boleh hanya mengandalkan
/// warna — makanya badge selalu punya teks (AKTIF / LIVE / OFFLINE),
/// bukan titik warna saja.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color = AppTheme.primary,
  });

  /// Badge hijau untuk "AKTIF".
  const StatusBadge.active({super.key, this.label = 'AKTIF'})
      : color = const Color(0xFF2E7D32);

  /// Badge merah untuk sesi live.
  const StatusBadge.live({super.key, this.label = '● LIVE'})
      : color = AppTheme.danger;

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
