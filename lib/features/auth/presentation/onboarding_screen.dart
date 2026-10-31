import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Onboarding Screen inspired directly by Screen 1 of the Dribbble design reference.
/// Features clean, spacious composition, friendly healthcare illustration,
/// prominent rounded pill CTA, and responsive layout.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = const [
    {
      'title': 'Komunikasi Inklusif\nTanpa Batas',
      'subtitle':
          'Jembatani interaksi antara teman Tuli dan masyarakat dengar dengan konversi Suara ke Teks dan Gerakan BISINDO ke Suara.',
    },
    {
      'title': 'Pencari Fasilitas\nKesehatan Terdekat',
      'subtitle':
          'Temukan rumah sakit, puskesmas, dan klinik dalam radius 10 km berbasis GPS dan data terbuka OpenStreetMap terverifikasi.',
    },
    {
      'title': 'Berbagi Lokasi Aman\nDalam Situasi Mendesak',
      'subtitle':
          'Kirimkan koordinat lokasi Anda ke faskes melalui lembar berbagi Android atau pantau pergerakan dengan teman terpercaya.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'Lewati',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Illustration (Dribbble Screen 1 inspired)
            Expanded(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 280,
                      height: 250,
                      child: TautIllustration.onboardingWelcome(height: 250),
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['subtitle']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Bottom Action Button (Dribbble styled large pill)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Mulai Sekarang'
                    : 'Lanjutkan',
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeLogin);
              },
              child: const Text(
                'Sudah punya akun? Masuk di sini',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
