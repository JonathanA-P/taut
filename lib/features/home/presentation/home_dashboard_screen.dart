import 'package:flutter/material.dart';
import 'home_page.dart';

/// Personalized and Friendly Dashboard for TAUT.
/// Mirrors and delegates to [HomePage], implementing the HTML prototype design.
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
