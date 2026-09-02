import 'package:flutter/material.dart';
import 'package:being_mind/routes/app_router.dart';
import 'package:being_mind/widgets/bouncing_wrapper.dart';

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
                    _buildExerciseCard(
                      context: context,
                      title: "Box\nBreathing",
                      duration: "4 min",
                      imageUrl:
                          "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=800&auto=format&fit=crop",
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
                      title: "Breathe with\nthe clouds",
                      duration: "7 min",
                      imageUrl:
                          "https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=800&auto=format&fit=crop",
                      accentColor: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
                      title: "Monthly stress\nreflection",
                      duration: "7 min",
                      imageUrl:
                          "https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?q=80&w=800&auto=format&fit=crop",
                      accentColor: const Color(0xFFF472B6),
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

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required String duration,
    required String imageUrl,
    required Color accentColor,
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
          color: const Color(0xFF12162A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left content: Title & Iridescent Play Button
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  top: 24.0,
                  bottom: 24.0,
                  right: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B5CF6), // Violet
                            Color(0xFF6366F1), // Indigo
                            Color(0xFF0EA5E9), // Sky blue
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right content: Atmospheric image with subtle frosted overlay & duration badge
            Expanded(
              flex: 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                  topLeft: Radius.circular(36),
                  bottomLeft: Radius.circular(36),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: accentColor.withValues(alpha: 0.25),
                        child: Icon(
                          Icons.spa_rounded,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 36,
                        ),
                      ),
                    ),
                    // Ambient gradient overlay to blend into dark cosmic theme
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFF12162A).withValues(alpha: 0.7),
                            Colors.transparent,
                            const Color(0xFF12162A).withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                    // Duration pill badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080A12).withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
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
