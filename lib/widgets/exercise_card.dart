import 'package:flutter/material.dart';
import 'package:being_mind/routes/app_router.dart';
import 'package:being_mind/widgets/bouncing_wrapper.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String imagePath;
  final Color accentColor;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imagePath,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    _buildCardImage(),
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

  Widget _buildCardImage() {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
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
