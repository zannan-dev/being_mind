import 'package:flutter/material.dart';
import 'package:being_mind/screens/home_screen.dart';
import 'package:being_mind/screens/breathing_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String breathing = '/breathing';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case breathing:
        final exerciseName = settings.arguments as String?;
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => BreathingScreen(
            exerciseName: exerciseName ?? 'Exercise',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
