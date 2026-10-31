import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taut/core/theme/app_theme.dart';

class TautActionButton extends StatelessWidget {
  const TautActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _variant = _ButtonVariant.primary;

  const TautActionButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _variant = _ButtonVariant.secondary;

  const TautActionButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _variant = _ButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final VoidCallback? handlePressed = onPressed == null
        ? null
        : () {
            HapticFeedback.lightImpact();
            onPressed!();
          };

    switch (_variant) {
      case _ButtonVariant.danger:
        return ElevatedButton(
          onPressed: handlePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.danger,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
      case _ButtonVariant.secondary:
        return OutlinedButton(onPressed: handlePressed, child: child);
      case _ButtonVariant.primary:
        return ElevatedButton(onPressed: handlePressed, child: child);
    }
  }
}

enum _ButtonVariant { primary, secondary, danger }

