import 'package:flutter/material.dart';

import 'package:being_mind/widgets/exercise_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF080A12), // Deep cosmic midnight
              Color(0xFF0D1224), // Indigo tone
              Color(0xFF141933), // Subtle violet dark atmosphere
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title & Ambient Accent
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 28.0,
                  bottom: 24.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DAILY MINDFULNESS",
                          style: TextStyle(
                            color: const Color(0xFFB8C8FF).withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Exercises",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFBAE6FD),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // List of exercises styled in dark frosted glass
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  children: [
                    ExerciseCard(
                      title: "Box\nBreathing",
                      subtitle: "FOCUS & CONTROL",
                      duration: "4 Cycles",
                      imagePath: "assets/images/box_breathing.jpg",
                      accentColor: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 16),
                    ExerciseCard(
                      title: "4-7-8 Relaxing\nBreath",
                      subtitle: "DEEP SLEEP & CALM",
                      duration: "4 Cycles",
                      imagePath: "assets/images/relaxing_breath.jpg",
                      accentColor: const Color(0xFFFB7185),
                    ),
                    const SizedBox(height: 16),
                    ExerciseCard(
                      title: "Resonant\nCoherence",
                      subtitle: "HEART HARMONY",
                      duration: "6 Cycles",
                      imagePath: "assets/images/app_icon.jpg",
                      accentColor: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

