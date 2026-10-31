import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Semantic status badge for indicating system states, active sessions, or stages.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.surfaceVariant,
    this.textColor = AppColors.onSurfaceVariant,
    this.icon,
  });

  factory StatusBadge.development() {
    return const StatusBadge(
      label: 'Tahap Fondasi / Belum Terhubung',
      backgroundColor: Color(0xFFFEF3C7),
      textColor: Color(0xFF92400E),
      icon: Icons.construction_rounded,
    );
  }

  factory StatusBadge.active() {
    return const StatusBadge(
      label: 'Aktif',
      backgroundColor: Color(0xFFDCFCE7),
      textColor: Color(0xFF166534),
      icon: Icons.check_circle_rounded,
    );
  }

  factory StatusBadge.idle() {
    return const StatusBadge(
      label: 'Siap',
      backgroundColor: Color(0xFFE0F2FE),
      textColor: Color(0xFF0369A1),
      icon: Icons.radio_button_checked_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
