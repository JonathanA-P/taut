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

class HomeShellScreen extends StatefulWidget {
  final int initialIndex;

  const HomeShellScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late PageController _pageController;
  bool _isAnimatingToPage = false;

  static const _primaryTabs = ['home', 'motion', 'stt', 'hub', 'comm', 'location', 'profile'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.initialIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = TautAppState();
        state.switchToTab(widget.initialIndex);
      });
    }
  }

  @override
  void didUpdateWidget(HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _isAnimatingToPage = true;
      _pageController.animateToPage(
        widget.initialIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ).then((_) {
        if (mounted) {
          _isAnimatingToPage = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, TautAppState state) {
    if (!_isAnimatingToPage && state.currentNavIndex != index) {
      HapticFeedback.selectionClick();
      state.switchToTab(index);
    }
  }

  void _onNavTap(int index, TautAppState state) {
    if (state.currentNavIndex == index && _primaryTabs.contains(state.currentPage)) {
      if (index == 0 && (state.currentPage == 'motion' || state.currentPage == 'stt')) {
        state.navigateTo('home');
      } else if (index == 1 && state.currentPage == 'comm') {
        state.stopHardwareTracks();
        state.endCommunicationSession();
        state.navigateTo('hub');
      }
      return;
    }
    _isAnimatingToPage = true;
    state.switchToTab(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ).then((_) {
        if (mounted) {
          _isAnimatingToPage = false;
        }
      });
    } else {
      _pageController.dispose();
      _pageController = PageController(initialPage: index);
      _isAnimatingToPage = false;
    }
  }

  void _syncPageWithNav(int targetIndex) {
    if (_pageController.hasClients &&
        !_isAnimatingToPage &&
        (_pageController.page?.round() ?? 0) != targetIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _pageController.hasClients &&
            !_isAnimatingToPage &&
            (_pageController.page?.round() ?? 0) != targetIndex) {
          _pageController.jumpToPage(targetIndex);
        }
      });
    } else if (!_pageController.hasClients && _pageController.initialPage != targetIndex) {
      _pageController.dispose();
      _pageController = PageController(initialPage: targetIndex);
    }
  }

  Widget _resolveTab0(TautAppState state) {
    if (state.currentPage == 'motion') {
      return const MotionToSoundScreen();
    }
    if (state.currentPage == 'stt') {
      return const SpeechToTextScreen();
    }
    return HomePage(
      onNavigateToCommunication: () => _onNavTap(1, state),
      onNavigateToLocation: () => _onNavTap(2, state),
      onNavigateToProfile: () => _onNavTap(3, state),
    );
  }

  Widget _resolveTab1(TautAppState state) {
    if (state.currentPage == 'comm') {
      return const CommunicationHubScreen();
    }
    return const CommunicationLandingScreen();
  }

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
        final isPrimaryTab = _primaryTabs.contains(state.currentPage);
        final safeIndex = activeNavIndex.clamp(0, 3);

        if (isPrimaryTab) {
          _syncPageWithNav(safeIndex);
        }

        return PopScope(
          canPop: !state.canPopPage && state.currentPage != 'motion' && state.currentPage != 'stt',
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              if (state.currentPage == 'motion' || state.currentPage == 'stt') {
                state.navigateTo('home');
              } else if (state.currentPage == 'comm') {
                state.stopHardwareTracks();
                state.endCommunicationSession();
                state.switchToTab(0);
              } else {
                state.popPage();
              }
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
                    child: isPrimaryTab
                        ? PageView(
                            controller: _pageController,
                            physics: const ClampingScrollPhysics(),
                            onPageChanged: (idx) => _onPageChanged(idx, state),
                            children: [
                              _resolveTab0(state),
                              _resolveTab1(state),
                              const LocationSharingScreen(),
                              const ProfileScreen(),
                            ],
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
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
                      child: _buildFloatingNavBar(context, state, safeIndex),
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
    int safeIndex,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 4;

          return Stack(
            children: [
              // Smooth sliding active pill indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.fastOutSlowIn,
                left: safeIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildNavItem(
                    index: 0,
                    label: 'Beranda',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    isActive: safeIndex == 0,
                    onTap: () => _onNavTap(0, state),
                  ),
                  _buildNavItem(
                    index: 1,
                    label: 'Komunikasi',
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    isActive: safeIndex == 1,
                    onTap: () => _onNavTap(1, state),
                  ),
                  _buildNavItem(
                    index: 2,
                    label: 'Lokasi',
                    icon: Icons.location_on_outlined,
                    activeIcon: Icons.location_on_rounded,
                    isActive: safeIndex == 2,
                    hasBadge: state.isSharingLocation,
                    onTap: () => _onNavTap(2, state),
                  ),
                  _buildNavItem(
                    index: 3,
                    label: 'Profil',
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    isActive: safeIndex == 3,
                    onTap: () => _onNavTap(3, state),
                  ),
                ],
              ),
            ],
          );
        },
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          onTap();
        },
        onTap: () {
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 200),
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
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.darkGreen
                      : const Color(0xFF66756B),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
