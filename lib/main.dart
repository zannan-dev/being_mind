import 'package:flutter/material.dart';
import 'package:being_mind/screens/home_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA084E8)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
