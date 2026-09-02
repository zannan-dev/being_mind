import 'package:flutter/material.dart';
import 'package:being_mind/routes/app_router.dart';
import 'package:being_mind/widgets/bouncing_wrapper.dart';

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
          bottom: false,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildExerciseCard(
                    context: context,
                    title: "Box\nBreathing",
                    duration: "4 min",
                    imageUrl: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=800&auto=format&fit=crop",
                    gradientColors: [const Color(0xFFB5A1F5), const Color(0xFFE2D4F8)],
                  ),
                  const SizedBox(height: 16),
                  _buildExerciseCard(
                    context: context,
                    title: "Breathe with\nthe clouds",
                    duration: "7 min",
                    imageUrl: "https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=800&auto=format&fit=crop",
                    gradientColors: [const Color(0xFFF9E0E3), const Color(0xFFF3E7F9)],
                  ),
                  const SizedBox(height: 16),
                  _buildExerciseCard(
                    context: context,
                    title: "Monthly stress\nreflection",
                    duration: "7 min",
                    imageUrl: "https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?q=80&w=800&auto=format&fit=crop",
                    gradientColors: [const Color(0xFFD0E1F9), const Color(0xFFE2D4F8)],
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
    required String imageUrl,
    required List<Color> gradientColors,
  }) {
    return BouncingWrapper(
      scaleDown: 0.03,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.breathing,
          arguments: title.replaceAll('\n', ' '),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D5775).withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 11, // Slightly wider left side for text
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 24.0, bottom: 24.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7B758B), // Muted grayish purple
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9691AD), // Muted purple for play button
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                    topLeft: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                  color: gradientColors.last,
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      right: 20,
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
