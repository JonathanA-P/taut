import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../../features/home/presentation/home_shell_screen.dart';
import '../../features/communication/presentation/communication_hub_screen.dart';
import '../../features/communication/speech_to_text/presentation/speech_to_text_screen.dart';
import '../../features/communication/motion_to_sound/presentation/motion_to_sound_screen.dart';
import '../../features/healthcare/presentation/healthcare_finder_screen.dart';
import '../../features/location_sharing/presentation/location_sharing_screen.dart';
import '../../features/friends/presentation/friends_placeholder_screen.dart';
import '../../features/auth/presentation/login_placeholder_screen.dart';
import '../../features/privacy/presentation/privacy_policy_screen.dart';

/// Centralized declarative router for TAUT navigation.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeHome:
        return MaterialPageRoute(builder: (_) => const HomeShellScreen());

      case AppConstants.routeCommunication:
        return MaterialPageRoute(
          builder: (_) => const CommunicationHubScreen(),
        );

      case AppConstants.routeSpeechToText:
        return MaterialPageRoute(builder: (_) => const SpeechToTextScreen());

      case AppConstants.routeMotionToSound:
        return MaterialPageRoute(builder: (_) => const MotionToSoundScreen());

      case AppConstants.routeHealthcare:
        return MaterialPageRoute(
          builder: (_) => const HealthcareFinderScreen(),
        );

      case AppConstants.routeLocationSharing:
        return MaterialPageRoute(builder: (_) => const LocationSharingScreen());

      case AppConstants.routeFriends:
        return MaterialPageRoute(
          builder: (_) => const FriendsPlaceholderScreen(),
        );

      case AppConstants.routeProfile:
        return MaterialPageRoute(
          builder: (_) => const LoginPlaceholderScreen(),
        );

      case AppConstants.routePrivacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
            body: Center(child: Text('Rute ${settings.name} tidak dikenali.')),
          ),
        );
    }
  }
}
