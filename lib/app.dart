import 'package:flutter/material.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';

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

