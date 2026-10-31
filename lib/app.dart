import 'package:flutter/material.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';

/// Root widget aplikasi TAUT.
///
/// Routing didelegasikan ke [AppRouter] supaya setiap fitur baru cukup
/// menambahkan satu case di router, tanpa mengubah file ini.
class TautApp extends StatelessWidget {
  final String? initialRoute;

  const TautApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAUT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute ?? AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
