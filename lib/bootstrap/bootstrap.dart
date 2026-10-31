import 'package:flutter/material.dart';
import 'package:taut/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TautApp());
}

