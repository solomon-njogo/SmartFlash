import 'package:flutter/material.dart';
import 'app/app.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();

  // Run the app
  runApp(const SmartFlashApp());
}
