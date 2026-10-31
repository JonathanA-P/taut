import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_modular_background.dart';
import '../../auth/presentation/edit_profile_screen.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../auth/presentation/settings_accessibility_screen.dart';
import '../../communication/presentation/communication_hub_screen.dart';
import '../../communication/presentation/communication_landing_screen.dart';
import '../../communication/motion_to_sound/presentation/motion_to_sound_screen.dart';
import '../../communication/speech_to_text/presentation/speech_to_text_screen.dart';
import '../../friends/presentation/add_friend_screen.dart';
import '../../friends/presentation/friends_list_screen.dart';
import '../../friends/presentation/live_location_screen.dart';
import '../../friends/presentation/manage_location_sharing_screen.dart';
import '../../healthcare/presentation/healthcare_detail_screen.dart';
import '../../healthcare/presentation/healthcare_finder_screen.dart';
import '../../location_sharing/presentation/location_sharing_screen.dart';
import '../../privacy/presentation/privacy_policy_screen.dart';
import 'home_page.dart';

class HomeShellScreen extends StatelessWidget {
  final int initialIndex;

  const HomeShellScreen({super.key, this.initialIndex = 0});

  Widget _resolveScreen(String page) {
    switch (page) {
      case 'home':
        return const HomePage();
      case 'hub':
        return const CommunicationLandingScreen();
      case 'comm':
        return const CommunicationHubScreen();
      case 'motion':
        return const MotionToSoundScreen();
      case 'stt':
        return const SpeechToTextScreen();
      case 'location':
        return const LocationSharingScreen();
      case 'finder':
        return const HealthcareFinderScreen();
      case 'detail':
        return const HealthcareDetailScreen();
      case 'friends':
        return const FriendsListScreen();
      case 'add':
        return const AddFriendScreen();
      case 'sharing':
        return const ManageLocationSharingScreen();
      case 'live':
        return const LiveLocationScreen();
      case 'profile':
        return const ProfileScreen();
      case 'edit':
        return const EditProfileScreen();
      case 'settings':
        return const SettingsAccessibilityScreen();
      case 'privacy':
        return const PrivacyPolicyScreen();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final activeNavIndex = state.currentNavIndex;

        return PopScope(
          canPop: !state.canPopPage,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              state.popPage();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Stationary modular background - unaffected by keyboard or tab swaps
                const Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: TautModularBackground(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: state.isNavbarVisible ? 86 : 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey(state.currentPage),
                        child: _resolveScreen(state.currentPage),
                      ),
                    ),
                  ),
                ),
                if (state.isNavbarVisible)
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 16,
                    child: SafeArea(
                      bottom: true,
                      child: _buildFloatingNavBar(context, state, activeNavIndex),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavBar(
    BuildContext context,
    TautAppState state,
    int activeIndex,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFAFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6EBE3), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18263D2F),
            blurRadius: 30,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            index: 0,
            label: 'Beranda',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            isActive: activeIndex == 0,
            onTap: () => state.switchToTab(0),
          ),
          _buildNavItem(
            index: 1,
            label: 'Komunikasi',
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            isActive: activeIndex == 1,
            onTap: () => state.switchToTab(1),
          ),
          _buildNavItem(
            index: 2,
            label: 'Lokasi',
            icon: Icons.location_on_outlined,
            activeIcon: Icons.location_on_rounded,
            isActive: activeIndex == 2,
            hasBadge: state.isSharingLocation,
            onTap: () => state.switchToTab(2),
          ),
          _buildNavItem(
            index: 3,
            label: 'Profil',
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            isActive: activeIndex == 3,
            onTap: () => state.switchToTab(3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.lightGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      isActive ? activeIcon : icon,
                      size: 22,
                      color: isActive
                          ? AppColors.darkGreen
                          : const Color(0xFF66756B),
                    ),
                  ),
                  if (hasBadge)
                    const Positioned(
                      right: -3,
                      top: -1,
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF8B4435),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.darkGreen
                      : const Color(0xFF66756B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

