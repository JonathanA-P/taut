import 'package:flutter/material.dart';
import 'package:taut/core/routing/app_router.dart';
import 'package:taut/core/theme/app_theme.dart';
import 'package:taut/shared/models/taut_app_state.dart';

class TautApp extends StatelessWidget {
  final String? initialRoute;

  const TautApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TautAppState(),
      builder: (context, _) {
        final scale = TautAppState().fontSize / 16.0;

        return MaterialApp(
          title: 'TAUT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: AppTheme.lightTheme.textTheme.apply(
              fontSizeFactor: scale,
            ),
          ),
          initialRoute: initialRoute ?? AppRoutes.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}

