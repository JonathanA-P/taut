import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.white;
    final effectiveBorder = borderColor ?? AppColors.lightGreen;
    final effectiveShadow = boxShadow ?? AppColors.cardShadow;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadow,
      ),
      child: Material(
        color: effectiveBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: effectiveBorder, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap!();
                },
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              )
            : Padding(
                padding: padding,
                child: child,
              ),
      ),
    );
  }
}

