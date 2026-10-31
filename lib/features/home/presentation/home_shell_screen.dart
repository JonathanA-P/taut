import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../communication/presentation/communication_hub_screen.dart';
import '../../location_sharing/presentation/location_sharing_screen.dart';
import '../../auth/presentation/profile_screen.dart';
import 'home_page.dart';

/// Main Application Shell containing the 4 primary feature destinations:
/// 1. Beranda
/// 2. Komunikasi
/// 3. Lokasi
/// 4. Profil
/// Preserves the established four-item bottom navigation from the prototype.
class HomeShellScreen extends StatefulWidget {
  final int initialIndex;

  const HomeShellScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchDestination(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    final destinations = [
      HomePage(
        onNavigateToCommunication: () => _switchDestination(1),
        onNavigateToHealthcare: () =>
            Navigator.pushNamed(context, AppConstants.routeHealthcare),
        onNavigateToLocation: () => _switchDestination(2),
        onNavigateToProfile: () => _switchDestination(3),
      ),
      const CommunicationHubScreen(),
      const LocationSharingScreen(),
      const ProfileScreen(),
    ];

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: destinations),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE6EBE3), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0C263D2F),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.lightGreen,
              elevation: 0,
              onDestinationSelected: _switchDestination,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Komunikasi',
                ),
                NavigationDestination(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.location_on_outlined),
                      if (state.isSharingLocation)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFF8B4435),
                          ),
                        ),
                    ],
                  ),
                  selectedIcon: const Icon(Icons.location_on_rounded),
                  label: 'Lokasi',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
