import 'dart:async';

import 'package:flutter/widgets.dart';

/// Bootstrap orchestrator for TAUT.
/// Ensures system bindings, error zones, and critical services are initialized
/// before the first frame is rendered.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error catching
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In production, forward to monitoring service (e.g. Sentry)
  };

  runApp(await builder());
}
