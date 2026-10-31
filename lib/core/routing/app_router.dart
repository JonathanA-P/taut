import 'package:flutter/material.dart';
import 'package:taut/features/home/presentation/home_page.dart';
import 'package:taut/shared/widgets/empty_state_placeholder.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String commHub = '/comm-hub';
  static const String speechToText = '/stt';
  static const String motionToSound = '/motion';
  static const String location = '/lokasi';
  static const String healthcareDetail = '/faskes-detail';
  static const String friendLocation = '/lokasi-teman';
  static const String myPosition = '/posisi-saya';
  static const String addFriend = '/tambah-teman';
  static const String manageSharing = '/kelola-berbagi';
  static const String profile = '/profil';
  static const String login = '/login';
  static const String register = '/register';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case AppRoutes.home:
        page = const HomePage();
        break;
      
      case AppRoutes.commHub:
        page = const _PlaceholderPage(
          title: 'Komunikasi',
          description:
              'Hub komunikasi (Speech-to-Text dan Motion-to-Sound) '
              'sedang dibangun oleh tim Komunikasi.',
        );
        break;
      case AppRoutes.speechToText:
        page = const _PlaceholderPage(
          title: 'Speech-to-Text',
          description: 'Suara diubah jadi teks. Fitur ini belum dibangun.',
        );
        break;
      case AppRoutes.motionToSound:
        page = const _PlaceholderPage(
          title: 'Motion-to-Sound',
          description:
              'Isyarat BISINDO diubah jadi suara. Fitur ini belum dibangun.',
        );
        break;
      case AppRoutes.location:
        page = const _PlaceholderPage(
          title: 'Lokasi',
          description:
              'Faskes terdekat dan Teman sedang dibangun oleh tim Lokasi.',
        );
        break;
      case AppRoutes.manageSharing:
        page = const _PlaceholderPage(
          title: 'Kelola Berbagi Lokasi',
          description: 'Kelola sesi berbagi lokasi. Fitur ini belum dibangun.',
        );
        break;
      case AppRoutes.myPosition:
        page = const _PlaceholderPage(
          title: 'Posisi Saya yang Dibagikan',
          description:
              'Posisi yang sedang kamu bagikan. Fitur ini belum dibangun.',
        );
        break;
      case AppRoutes.friendLocation:
        page = const _PlaceholderPage(
          title: 'Lokasi Teman',
          description: 'Posisi teman yang berbagi. Fitur ini belum dibangun.',
        );
        break;
      case AppRoutes.profile:
        page = const _PlaceholderPage(
          title: 'Profil',
          description: 'Profil dan pengaturan. Fitur ini belum dibangun.',
        );
        break;
      default:
        page = const _PlaceholderPage(
          title: 'Halaman tidak ditemukan',
          description: 'Rute yang dibuka belum tersedia di aplikasi ini.',
        );
    }

    return MaterialPageRoute<void>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyStatePlaceholder(
        title: title,
        description: description,
      ),
    );
  }
}
