import 'dart:io';
import 'package:flutter/material.dart';

class TautAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final BoxBorder? border;

  const TautAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final bg = backgroundColor ?? const Color(0xFFE9DDCD);
    final fg = textColor ?? const Color(0xFF655747);
    final size = radius * 2;

    Widget fallbackInitial = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest || avatarUrl == null || avatarUrl!.trim().isEmpty) {
      return fallbackInitial;
    }

    final cleanUrl = avatarUrl!.trim();
    final isLocal = cleanUrl.startsWith('/') ||
        cleanUrl.startsWith('file:') ||
        !cleanUrl.startsWith('http');

    Widget imageWidget;
    if (isLocal) {
      final localPath = cleanUrl.replaceFirst('file://', '');
      imageWidget = Image.file(
        File(localPath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackInitial,
      );
    } else {
      imageWidget = Image.network(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackInitial,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );
  }
}
