import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/sayo_theme.dart';
import 'app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SayoApp());
}

class SayoApp extends StatelessWidget {
  const SayoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAYO',
      debugShowCheckedModeBanner: false,
      theme: SayoTheme.light,
      routerConfig: appRouter,
    );
  }
}
