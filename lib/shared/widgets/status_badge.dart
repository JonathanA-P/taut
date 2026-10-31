import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Semantic status badge for indicating system states, active sessions, or stages.
/// Styled as a soft, pill-shaped badge in the sage green healthcare aesthetic.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.lightGreen,
    this.textColor = AppColors.darkGreen,
    this.icon,
  });

  factory StatusBadge.development() {
    return const StatusBadge(
      label: 'Tahap Fondasi • Siap Integrasi',
      backgroundColor: AppColors.accentMtsBg,
      textColor: AppColors.onAccentMts,
      icon: Icons.info_outline_rounded,
    );
  }

  factory StatusBadge.active({String label = 'Semua Sistem Siap'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.successBg,
      textColor: AppColors.success,
      icon: Icons.check_circle_rounded,
    );
  }

  factory StatusBadge.idle({String label = 'Siap Digunakan'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.lightGreen,
      textColor: AppColors.darkGreen,
      icon: Icons.radio_button_checked_rounded,
    );
  }

  factory StatusBadge.category(String text, {Color? bg, Color? fg}) {
    return StatusBadge(
      label: text,
      backgroundColor: bg ?? AppColors.lightGreen,
      textColor: fg ?? AppColors.darkGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
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
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
