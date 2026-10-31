import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../../features/home/presentation/home_shell_screen.dart';
import '../../features/home/presentation/home_dashboard_screen.dart';
import '../../features/communication/presentation/communication_hub_screen.dart';
import '../../features/communication/speech_to_text/presentation/speech_to_text_screen.dart';
import '../../features/communication/motion_to_sound/presentation/motion_to_sound_screen.dart';
import '../../features/healthcare/presentation/healthcare_finder_screen.dart';
import '../../features/healthcare/presentation/healthcare_detail_screen.dart';
import '../../features/healthcare/domain/healthcare_facility.dart';
import '../../features/location_sharing/presentation/location_sharing_screen.dart';
import '../../features/location_sharing/presentation/share_location_to_healthcare_screen.dart';
import '../../features/friends/presentation/friends_list_screen.dart';
import '../../features/friends/presentation/add_friend_screen.dart';
import '../../features/friends/presentation/live_location_screen.dart';
import '../../features/friends/presentation/manage_location_sharing_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/edit_profile_screen.dart';
import '../../features/auth/presentation/settings_accessibility_screen.dart';
import '../../features/privacy/presentation/privacy_policy_screen.dart';

/// Centralized declarative router for TAUT navigation.
/// Maps all 20 primary application screens and flows.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeHome:
        return MaterialPageRoute(builder: (_) => const HomeShellScreen());

      case AppConstants.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppConstants.routeOnboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppConstants.routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppConstants.routeRegister:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppConstants.routeHomeDashboard:
        return MaterialPageRoute(builder: (_) => const HomeDashboardScreen());

      case AppConstants.routeCommunication:
        return MaterialPageRoute(builder: (_) => const CommunicationHubScreen());

      case AppConstants.routeSpeechToText:
        return MaterialPageRoute(builder: (_) => const SpeechToTextScreen());

      case AppConstants.routeMotionToSound:
        return MaterialPageRoute(builder: (_) => const MotionToSoundScreen());

      case AppConstants.routeLocationHub:
      case AppConstants.routeLocationSharing:
        return MaterialPageRoute(builder: (_) => const LocationSharingScreen());

      case AppConstants.routeHealthcare:
        return MaterialPageRoute(builder: (_) => const HealthcareFinderScreen());

      case AppConstants.routeHealthcareDetail:
        final facility = settings.arguments as HealthcareFacility? ??
            const HealthcareFacility(
              id: 'osm-default',
              name: 'RSUD Dr. Saiful Anwar',
              category: 'Rumah Sakit',
              address: 'Jl. Jaksa Agung Suprapto No. 2, Klojen, Malang',
              latitude: -7.9723,
              longitude: 112.6318,
              distanceMeters: 1250,
              isWheelchairAccessible: true,
            );
        return MaterialPageRoute(
          builder: (_) => HealthcareDetailScreen(facility: facility),
        );

      case AppConstants.routeShareHealthcare:
        final facility = settings.arguments as HealthcareFacility?;
        return MaterialPageRoute(
          builder: (_) => ShareLocationToHealthcareScreen(targetFacility: facility),
        );

      case AppConstants.routeFriends:
        return MaterialPageRoute(builder: (_) => const FriendsListScreen());

      case AppConstants.routeAddFriend:
        return MaterialPageRoute(builder: (_) => const AddFriendScreen());

      case AppConstants.routeLiveLocation:
        return MaterialPageRoute(builder: (_) => const LiveLocationScreen());

      case AppConstants.routeManageLocationSharing:
        return MaterialPageRoute(
          builder: (_) => const ManageLocationSharingScreen(),
        );

      case AppConstants.routeProfile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppConstants.routeEditProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppConstants.routeSettings:
        return MaterialPageRoute(
          builder: (_) => const SettingsAccessibilityScreen(),
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
