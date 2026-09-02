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
                      subtitle: "FOCUS & CONTROL",
                      duration: "4 Cycles",
                      imagePath: "assets/images/box_breathing.jpg",
                      accentColor: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
                      title: "4-7-8 Relaxing\nBreath",
                      subtitle: "DEEP SLEEP & CALM",
                      duration: "4 Cycles",
                      imagePath: "assets/images/relaxing_breath.jpg",
                      accentColor: const Color(0xFFFB7185),
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context: context,
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

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String duration,
    required String imagePath,
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
            // Left content: Subtitle & Title
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.18,
                        letterSpacing: -0.3,
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
                    _buildCardImage(imagePath, accentColor),
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

  Widget _buildCardImage(String path, Color accentColor) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(accentColor),
      );
    } else {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(accentColor),
      );
    }
  }

  Widget _buildPlaceholder(Color accentColor) {
    return Container(
      color: accentColor.withValues(alpha: 0.25),
      child: Icon(
        Icons.spa_rounded,
        color: Colors.white.withValues(alpha: 0.4),
        size: 36,
      ),
    );
  }
}

