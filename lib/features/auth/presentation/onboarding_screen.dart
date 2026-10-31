import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/taut_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),
            _buildPageIndicator(),
            _buildBottomAction(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage == 0)
            RichText(
              text: const TextSpan(
                text: 'taut',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  letterSpacing: -1.5,
                ),
                children: [
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      color: Color(0xFF8AAB7E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.darkGreen,
              onPressed: () => _goToPage(_currentPage - 1),
              tooltip: 'Kembali',
            ),
          if (_currentPage == 1)
            const Text(
              'TAUT FITUR',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            )
          else if (_currentPage == 2)
            const Text(
              'TAUT PEDULI',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            )
          else
            const SizedBox.shrink(),
          TextButton(
            onPressed: _goToWelcome,
            child: const Text(
              'Lewati',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3EDE0), Color(0xFFD8E7D5)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10263D2F),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: TautIllustration.friendlyConversationHero(
                width: 230,
                height: 180,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SALING MEMAHAMI • 1/3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ceritamu layak\nuntuk didengar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ruang komunikasi yang hangat, setara, dan menghubungkan teman Tuli dan Dengar tanpa sekat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3EDE0), Color(0xFFD8E7D5)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10263D2F),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureCard(
                    icon: Icons.mic_none_rounded,
                    iconBg: const Color(0xFFE5EEE5),
                    iconColor: AppColors.primary,
                    title: 'Ucapan ➔ Teks',
                    subtitle: 'Dengar tulisan',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  _buildFeatureCard(
                    icon: Icons.front_hand_rounded,
                    iconBg: const Color(0xFFF2EADD),
                    iconColor: const Color(0xFF7A5E33),
                    title: 'Isyarat ➔ Suara',
                    subtitle: 'BISINDO suara',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'KOMUNIKASI DUA ARAH • 2/3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Dua arah,\nsatu percakapan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Suara diubah menjadi teks seketika, dan isyarat tangan diterjemahkan menjadi suara yang ramah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12263D2F),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3EDE0), Color(0xFFD8E7D5)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10263D2F),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 270,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12263D2F),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EEE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fasilitas Ramah Disabilitas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Klinik & RS dengan juru bahasa',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFFE4E9E1), height: 1),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Lokasi Terenkripsi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '0,8 km',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AMAN & DEKAT • 3/3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tetap dekat,\nke mana pun pergi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Temukan faskes ramah aksesibilitas dan bagikan lokasi secara aman hanya kepada orang terpercaya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentPage;
          return GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFD0DDD0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomAction() {
    final isLast = _currentPage == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            if (isLast) {
              _goToWelcome();
            } else {
              _goToPage(_currentPage + 1);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: const Color(0x33527B5D),
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(
            isLast ? 'Selesai & Masuk TAUT' : 'Lanjut',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
