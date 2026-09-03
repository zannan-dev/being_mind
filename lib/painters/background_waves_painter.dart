import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the delicate acoustic / breath frequency ribbons flowing behind the sphere.
class BackgroundWavesPainter extends CustomPainter {
  final double animationValue;
  final double breathProgress;
  final bool isPlaying;
  final Offset orbOffset;

  BackgroundWavesPainter({
    required this.animationValue,
    required this.breathProgress,
    required this.isPlaying,
    this.orbOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2 + orbOffset.dy * 0.25;
    final centerX = size.width / 2 + orbOffset.dx * 0.25;
    final orbRadius = 135.0;

    final breathWaveModulation = isPlaying
        ? 0.09 * sin(breathProgress * 2 * pi).abs()
        : 0.02 * sin(animationValue * 2 * pi).abs();
    final baseAlpha = 0.22 + breathWaveModulation;
    const int numLines = 9;

    // Paint left waves
    for (int i = 0; i < numLines; i++) {
      final path = Path();
      final lineProgress = i / (numLines - 1);
      final yOffset = (lineProgress - 0.5) * 55.0;
      final phaseShift = i * 0.45 + animationValue * 2 * pi;

      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color =
            Color.lerp(
              const Color(0xFF06B6D4),
              const Color(0xFFA855F7),
              lineProgress,
            )!.withValues(
              alpha: baseAlpha * (1.0 - (lineProgress - 0.5).abs() * 0.8),
            );

      bool first = true;
      final startX = 0.0;
      final endX = centerX - (orbRadius * 0.45);

      for (double x = startX; x <= endX; x += 4) {
        final distFromCenter = (endX - x) / (endX - startX);
        final envelope = sin(distFromCenter * pi);
        final y =
            centerY + yOffset + sin(x * 0.035 - phaseShift) * (14.0 * envelope);

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    }

    // Paint right waves
    for (int i = 0; i < numLines; i++) {
      final path = Path();
      final lineProgress = i / (numLines - 1);
      final yOffset = (lineProgress - 0.5) * 55.0;
      final phaseShift = i * 0.45 + animationValue * 2 * pi;

      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color =
            Color.lerp(
              const Color(0xFFA855F7),
              const Color(0xFFFB7185),
              lineProgress,
            )!.withValues(
              alpha: baseAlpha * (1.0 - (lineProgress - 0.5).abs() * 0.8),
            );

      bool first = true;
      final startX = centerX + (orbRadius * 0.45);
      final endX = size.width;

      for (double x = startX; x <= endX; x += 4) {
        final distFromCenter = (x - startX) / (endX - startX);
        final envelope = sin(distFromCenter * pi);
        final y =
            centerY + yOffset + sin(x * 0.035 + phaseShift) * (14.0 * envelope);

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.orbOffset != orbOffset;
  }
}
