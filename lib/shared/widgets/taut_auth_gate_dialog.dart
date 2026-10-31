import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';

void showAuthGateDialog(
  BuildContext context, {
  required String featureTitle,
  String? featureDescription,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E2D5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Perlu Masuk Akun',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                featureDescription ??
                    'Fitur $featureTitle hanya dapat digunakan oleh akun terdaftar. Masuk sekarang untuk menikmati seluruh kemudahan komunikasi dan interaksi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk atau Buat Akun',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'Nanti Saja',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
