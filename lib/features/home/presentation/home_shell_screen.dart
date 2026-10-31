import 'package:flutter/material.dart';

import '../../communication/presentation/communication_hub_screen.dart';
import '../../healthcare/presentation/healthcare_finder_screen.dart';
import '../../location_sharing/presentation/location_sharing_screen.dart';
import '../../auth/presentation/profile_screen.dart';

/// Main Application Shell containing the 4 primary feature destinations.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _destinations = const [
    CommunicationHubScreen(),
    HealthcareFinderScreen(),
    LocationSharingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _destinations),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
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
    );
  }
}
