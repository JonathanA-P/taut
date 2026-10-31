import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Communication Landing / Pre-Communication Screen ("Ruang komunikasi")
/// Strictly implementing the HTML prototype and user design:
/// - Screen title: "Ruang komunikasi" with back button
/// - Central two-way communication illustration
/// - Heading: "Dua arah. Satu percakapan."
/// - Subtitle: "Baca ucapan teman dengar, lalu balas lewat isyarat atau tulisan tanpa berpindah layar."
/// - Primary CTA: "Mulai komunikasi" -> routes to live session ("Komunikasi langsung")
class CommunicationLandingScreen extends StatelessWidget {
  const CommunicationLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Back Button + Screen Title
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (state.canPopPage) {
                        state.popPage();
                      } else {
                        state.switchToTab(0);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4E9E1)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.darkGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Ruang komunikasi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Central Communication Illustration
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: TautIllustration.communicationHero(height: 250),
                ),
              ),
              const SizedBox(height: 28),

              // Headings and description
              const Text(
                'Dua arah.\nSatu percakapan.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                  height: 1.2,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Baca ucapan teman dengar, lalu balas lewat isyarat atau tulisan tanpa berpindah layar.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF66756B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Primary CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    state.navigateTo('comm');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mulai komunikasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
