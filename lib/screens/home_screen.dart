import 'package:flutter/material.dart';
import 'package:being_mind/screens/breathing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB5A1F5), // Deeper purple top
              Color(0xFFE2D4F8), // Lighter middle
              Color(0xFFF1E6F9), // Soft pinkish bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Title
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 24.0),
                child: Text(
                  "Exercises",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
              ),



              // List of exercises
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    _buildExerciseCard(
                      context: context,
                      title: "Box Breathing",
                      duration: "4 min",
                      gradientColors: [Color(0xFFD4C4FA), Color(0xFFF3E7F9)],
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
                      title: "Breathe with the clouds",
                      duration: "7 min",
                      gradientColors: [Color(0xFFF9E0E3), Color(0xFFF3E7F9)],
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
                      title: "Monthly stress reflection",
                      duration: "7 min",
                      gradientColors: [Color(0xFFD0E1F9), Color(0xFFE2D4F8)],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required String duration,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreathingScreen(exerciseName: title),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9072EE), // Deep purple for play
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Adding a subtle decorative circle to mimic the 3D art in screenshot
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
