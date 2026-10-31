import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 52.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveFg = foregroundColor ?? (isOutlined ? AppColors.textPrimary : AppColors.white);

    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: effectiveFg,
        letterSpacing: 0.1,
      ),
    );

    if (isOutlined) {
      final style = OutlinedButton.styleFrom(
        foregroundColor: effectiveFg,
        minimumSize: Size(width ?? double.infinity, height),
        side: BorderSide(
          color: backgroundColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );

      if (icon != null) {
        return OutlinedButton.icon(
          onPressed: onPressed,
          style: style,
          icon: Icon(icon, size: 20, color: effectiveFg),
          label: textWidget,
        );
      }
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      );
    }

    final elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      elevation: 0,
      minimumSize: Size(width ?? double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: elevatedStyle,
        icon: Icon(icon, size: 20, color: effectiveFg),
        label: textWidget,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: elevatedStyle,
      child: textWidget,
    );
  }
}

