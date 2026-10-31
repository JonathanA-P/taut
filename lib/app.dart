import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root Application Widget for TAUT.
class TautApp extends StatelessWidget {
  const TautApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppConstants.routeHome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
