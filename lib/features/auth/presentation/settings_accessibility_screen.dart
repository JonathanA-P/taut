import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/models/taut_app_state.dart';
import 'onboarding_screen.dart';

/// Settings & Accessibility Screen strictly implementing the TAUT HTML prototype:
/// - Screen title: "Pengaturan"
/// - Heading: "Kenyamanan untukmu"
/// - Subtitle: "Sesuaikan cara kamu menggunakan TAUT."
/// - Font scale selector: 16px (Standar), 19px (Besar), 22px (Sangat besar)
/// - Preview text box showing dynamic font scaling: "Halo, senang bisa saling memahami."
/// - "Putar suara setelah konfirmasi" section with hint
/// - "Mulai ulang onboarding" button
/// - "Reset seluruh demo" button
class SettingsAccessibilityScreen extends StatelessWidget {
  const SettingsAccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: (Navigator.canPop(context) || state.canPopPage)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkGreen,
                    onPressed: () {
                      if (state.canPopPage) {
                        state.popPage();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kenyamanan untukmu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sesuaikan cara kamu menggunakan TAUT.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Settings Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEDF0E9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05263D2F),
                          blurRadius: 16,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ukuran teks',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD9E2D5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<double>(
                              value: state.fontSize,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              onChanged: (val) {
                                if (val != null) {
                                  state.setFontSize(val);
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 16.0,
                                  child: Text(
                                    'Standar · 16px',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 19.0,
                                  child: Text(
                                    'Besar · 19px',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 22.0,
                                  child: Text(
                                    'Sangat besar · 22px',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Preview Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3EB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Halo, senang bisa saling memahami.',
                            style: TextStyle(
                              fontSize: state.fontSize,
                              color: const Color(0xFF5B6E55),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Divider(color: Color(0xFFE4E9E1), height: 1),
                        ),

                        // Confirmation section
                        const Text(
                          'Putar suara setelah konfirmasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hasil isyarat dapat diperiksa dan disunting sebelum kamu menekan Putar.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Restart Onboarding Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        foregroundColor: AppColors.darkGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Mulai ulang onboarding',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Reset Demo Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        state.resetDemo();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Demo dikembalikan ke keadaan awal.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFB9C9B6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Reset seluruh demo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
