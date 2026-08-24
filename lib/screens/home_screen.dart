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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          radius: 20,
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello,",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14),
                            ),
                            const Text(
                              "Kristina!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none,
                          color: Colors.white, size: 24),
                    )
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  "My plans",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
              ),

              // Filters (Mockup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "October",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "All meditation",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "12",
                              style: TextStyle(color: Color(0xFF8C64F5), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
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
              
              // Bottom Nav (Mockup)
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFFC7B1F6).withOpacity(0.8),
                      const Color(0xFFE4D5FB).withOpacity(0.0),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.home, color: Colors.white, size: 28),
                    Icon(Icons.access_time_filled, color: Colors.white.withOpacity(0.5), size: 28),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.spa, color: Colors.white, size: 24),
                      ),
                    ),
                    Icon(Icons.bookmark, color: Colors.white.withOpacity(0.5), size: 28),
                    Icon(Icons.grid_view_rounded, color: Colors.white.withOpacity(0.5), size: 28),
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
              color: Colors.black.withOpacity(0.05),
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
                          color: Colors.white.withOpacity(0.2),
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
