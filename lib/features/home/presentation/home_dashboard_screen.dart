import 'package:flutter/material.dart';
import 'home_page.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToCommunication;
  final VoidCallback? onNavigateToHealthcare;
  final VoidCallback? onNavigateToLocationSharing;
  final VoidCallback? onNavigateToProfile;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToCommunication,
    this.onNavigateToHealthcare,
    this.onNavigateToLocationSharing,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return HomePage(
      onNavigateToCommunication: onNavigateToCommunication,
      onNavigateToHealthcare: onNavigateToHealthcare,
      onNavigateToLocation: onNavigateToLocationSharing,
      onNavigateToProfile: onNavigateToProfile,
    );
  }
}

