import 'package:flutter/material.dart';
import 'package:being_mind/routes/app_router.dart';

void main() {
  runApp(const BoxBreathingApp());
}

class BoxBreathingApp extends StatelessWidget {
  const BoxBreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Box Breathing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        platform: TargetPlatform.iOS,
      ),
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
