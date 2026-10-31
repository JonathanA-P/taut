import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../communication/presentation/communication_hub_screen.dart';
import '../../healthcare/presentation/healthcare_finder_screen.dart';
import '../../location_sharing/presentation/location_sharing_screen.dart';
import '../../auth/presentation/profile_screen.dart';
import 'home_dashboard_screen.dart';

/// Main Application Shell containing the 4 primary feature destinations.
/// Preserves the established four-item bottom navigation:
/// 1. Komunikasi
/// 2. Faskes
/// 3. Bagi Lokasi
/// 4. Profil
/// Features seamless integration with the Personal Home Dashboard.
class HomeShellScreen extends StatefulWidget {
  final int initialIndex;

  const HomeShellScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late int _currentIndex;
  bool _showPersonalDashboard = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchDestination(int index) {
    setState(() {
      _currentIndex = index;
      _showPersonalDashboard = false;
    });
  }

  void _openDashboard() {
    setState(() {
      _showPersonalDashboard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      CommunicationHubScreen(onOpenDashboard: _openDashboard),
      const HealthcareFinderScreen(),
      const LocationSharingScreen(),
      const ProfileScreen(),
    ];

    final bodyWidget = _showPersonalDashboard
        ? HomeDashboardScreen(
            onNavigateToCommunication: () => _switchDestination(0),
            onNavigateToHealthcare: () => _switchDestination(1),
            onNavigateToLocationSharing: () => _switchDestination(2),
            onNavigateToProfile: () => _switchDestination(3),
          )
        : IndexedStack(index: _currentIndex, children: destinations);

    return Scaffold(
      appBar: _showPersonalDashboard
          ? null
          : AppBar(
              toolbarHeight: 0, // Handled inside individual screens
              elevation: 0,
            ),
      body: bodyWidget,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.lightGreen, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A263D2F),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _showPersonalDashboard ? 0 : _currentIndex,
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.sageGreen.withValues(alpha: 0.7),
          elevation: 0,
          onDestinationSelected: (index) {
            _switchDestination(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded),
              label: 'Komunikasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_hospital_outlined),
              selectedIcon: Icon(Icons.local_hospital_rounded),
              label: 'Faskes',
            ),
            NavigationDestination(
              icon: Icon(Icons.share_location_outlined),
              selectedIcon: Icon(Icons.share_location_rounded),
              label: 'Bagi Lokasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
