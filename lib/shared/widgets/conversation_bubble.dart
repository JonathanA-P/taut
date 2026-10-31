import 'package:flutter/material.dart';
import 'package:taut/core/theme/app_theme.dart';

class ConversationBubble extends StatelessWidget {
  const ConversationBubble({
    super.key,
    required this.text,
    required this.isFromUser,
    this.isFinal = true,
  });

  final String text;
  final bool isFromUser;
  final bool isFinal;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromUser ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isFromUser
              ? null
              : Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isFromUser ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            if (!isFinal) ...[
              const SizedBox(height: 4),
              Text(
                'Mendengarkan...',
                style: TextStyle(
                  fontSize: 12,
                  color: isFromUser
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

