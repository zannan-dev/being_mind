import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the organic, iridescent, translucent soap-bubble / glowing glass orb.
class IridescentBubblePainter extends CustomPainter {
  final double fluidPhase;
  final double breathProgress;
  final bool isPlaying;
  final double dragStretch;
  final double dragAngle;

  IridescentBubblePainter({
    required this.fluidPhase,
    required this.breathProgress,
    required this.isPlaying,
    this.dragStretch = 0.0,
    this.dragAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.45;

    // 1. Generate Organic Fluid Perimeter Path using harmonic perturbation & touch drag deformation
    final outerPath = _generateOrganicPath(
      center: center,
      baseRadius: baseRadius,
      phase: fluidPhase * 2 * pi,
      perturbationScale: 1.0,
      dragStretch: dragStretch,
      dragAngle: dragAngle,
    );

    final bounds = Rect.fromCircle(center: center, radius: baseRadius + 20);

    // -------------------------------------------------------------
    // -------------------------------------------------------------
    // PASS 1: Volumetric Ambient Aura (Matching the icon's triad aura)
    // -------------------------------------------------------------
    final auraPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFF06B6D4).withValues(alpha: 0.22), // Cyan (left)
          const Color(0xFFA855F7).withValues(alpha: 0.28), // Violet (top)
          const Color(0xFFFB7185).withValues(alpha: 0.24), // Coral rose (right)
          const Color(0xFFFDBA74).withValues(alpha: 0.16), // Warm peach (bottom)
          const Color(0xFF06B6D4).withValues(alpha: 0.22),
        ],
        stops: const [0.0, 0.30, 0.62, 0.84, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.35))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, baseRadius * 1.25, auraPaint);

    // -------------------------------------------------------------
    // PASS 2: Translucent Midnight Glass Body (Clipped to organic shape)
    // -------------------------------------------------------------
    canvas.save();
    canvas.clipPath(outerPath);

    // Deep translucent glass interior with soft center darkness
    final glassBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.15, -0.15),
        radius: 0.95,
        colors: [
          const Color(0xFF0D1226).withValues(alpha: 0.50),
          const Color(0xFF070914).withValues(alpha: 0.72),
          const Color(0xFF1E1B4B).withValues(alpha: 0.40),
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(bounds);
    canvas.drawPath(outerPath, glassBodyPaint);

    // -------------------------------------------------------------
    // PASS 3: The Three Chromatic Spheres (Matching the App Icon Triad)
    // -------------------------------------------------------------
    final circleRadius = baseRadius * 0.52;

    // Subtle ambient orbital drift
    final driftXTop = 4.0 * sin(fluidPhase * 2 * pi);
    final driftYTop = 4.0 * cos(fluidPhase * 2 * pi);
    final driftXLeft = 4.0 * cos(fluidPhase * 2 * pi + 2 * pi / 3);
    final driftYLeft = 4.0 * sin(fluidPhase * 2 * pi + 2 * pi / 3);
    final driftXRight = 4.0 * cos(fluidPhase * 2 * pi + 4 * pi / 3);
    final driftYRight = 4.0 * sin(fluidPhase * 2 * pi + 4 * pi / 3);

    // --- CIRCLE 1: TOP (Radiant Amethyst-Violet Sphere) ---
    final topCenter = Offset(
      center.dx + driftXTop,
      center.dy - baseRadius * 0.28 + driftYTop,
    );
    final topBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.10, -0.20),
        radius: 0.85,
        colors: [
          const Color(0xFFE879F9).withValues(alpha: 0.44), // Luminous lilac core
          const Color(0xFFA855F7).withValues(alpha: 0.36), // Electric violet
          const Color(0xFF7C3AED).withValues(alpha: 0.18), // Deep purple
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: topCenter, radius: circleRadius))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(topCenter, circleRadius, topBodyPaint);

    final topRimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = const Color(0xFFC084FC).withValues(alpha: 0.70)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(topCenter, circleRadius * 0.98, topRimGlow);

    final topCrispRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.80),
          const Color(0xFFF5D0FE).withValues(alpha: 0.65),
          const Color(0xFFA855F7).withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.80),
        ],
      ).createShader(Rect.fromCircle(center: topCenter, radius: circleRadius));
    canvas.drawCircle(topCenter, circleRadius, topCrispRim);

    // --- CIRCLE 2: BOTTOM-LEFT (Electric Cyan-Blue Sphere) ---
    final leftCenter = Offset(
      center.dx - baseRadius * 0.26 + driftXLeft,
      center.dy + baseRadius * 0.20 + driftYLeft,
    );
    final leftBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.20, -0.15),
        radius: 0.85,
        colors: [
          const Color(0xFF67E8F9).withValues(alpha: 0.46), // Brilliant aqua core
          const Color(0xFF06B6D4).withValues(alpha: 0.36), // Electric cyan
          const Color(0xFF0284C7).withValues(alpha: 0.18), // Deep sky-blue
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: leftCenter, radius: circleRadius))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(leftCenter, circleRadius, leftBodyPaint);

    final leftRimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(leftCenter, circleRadius * 0.98, leftRimGlow);

    final leftCrispRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.80),
          const Color(0xFFBAE6FD).withValues(alpha: 0.65),
          const Color(0xFF0284C7).withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.80),
        ],
      ).createShader(Rect.fromCircle(center: leftCenter, radius: circleRadius));
    canvas.drawCircle(leftCenter, circleRadius, leftCrispRim);

    // --- CIRCLE 3: BOTTOM-RIGHT (Warm Peach-Rose / Sunset Coral Sphere) ---
    final rightCenter = Offset(
      center.dx + baseRadius * 0.26 + driftXRight,
      center.dy + baseRadius * 0.20 + driftYRight,
    );
    final rightBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.18, -0.15),
        radius: 0.85,
        colors: [
          const Color(0xFFFDA4AF).withValues(alpha: 0.46), // Peach-rose core
          const Color(0xFFFB7185).withValues(alpha: 0.36), // Coral rose
          const Color(0xFFF43F5E).withValues(alpha: 0.18), // Sunset crimson
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: rightCenter, radius: circleRadius))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(rightCenter, circleRadius, rightBodyPaint);

    final rightRimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = const Color(0xFFFDBA74).withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawCircle(rightCenter, circleRadius * 0.98, rightRimGlow);

    final rightCrispRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.80),
          const Color(0xFFFED7AA).withValues(alpha: 0.65),
          const Color(0xFFFB7185).withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.80),
        ],
      ).createShader(Rect.fromCircle(center: rightCenter, radius: circleRadius));
    canvas.drawCircle(rightCenter, circleRadius, rightCrispRim);

    canvas.restore(); // Restore clip

    // -------------------------------------------------------------
    // PASS 4: Radiant Fresnel Rim Lighting (Matching App Icon Edge)
    // -------------------------------------------------------------
    // A) Soft blurred rim glow matching the triad hues
    final rimGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.70), // Cyan (left)
          const Color(0xFFA855F7).withValues(alpha: 0.85), // Violet (top)
          const Color(0xFFFB7185).withValues(alpha: 0.75), // Coral Rose (right)
          const Color(0xFFFDBA74).withValues(alpha: 0.50), // Peach Gold (bottom)
          const Color(0xFF38BDF8).withValues(alpha: 0.70),
        ],
        stops: const [0.0, 0.28, 0.60, 0.82, 1.0],
      ).createShader(bounds)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(outerPath, rimGlowPaint);

    // B) Sharp, brilliant crisp rim line
    final crispRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFFBAE6FD), // Crisp ice cyan
          const Color(0xFFE9D5FF), // Pale lilac
          const Color(0xFFFBCFE8), // Pale rose
          const Color(0xFFFFFFFF), // Brilliant white highlight
          const Color(0xFF93C5FD), // Light blue
          const Color(0xFFBAE6FD),
        ],
        stops: const [0.0, 0.3, 0.55, 0.75, 0.9, 1.0],
      ).createShader(bounds);
    canvas.drawPath(outerPath, crispRimPaint);
  }

  /// Generates a smooth, organic, fluid closed contour using harmonic sinusoidal radius perturbation,
  /// touch/drag elongation, and Catmull-Rom spline to cubic Bezier interpolation.
  Path _generateOrganicPath({
    required Offset center,
    required double baseRadius,
    required double phase,
    required double perturbationScale,
    double dragStretch = 0.0,
    double dragAngle = 0.0,
  }) {
    const int segments = 18;
    final List<Offset> points = [];

    for (int i = 0; i < segments; i++) {
      final angle = (i * 2 * pi) / segments;

      // Seamless harmonic fluid wobble formula (integer multipliers guarantee zero-pop seamless looping)
      final d1 = 0.034 * sin(2 * angle + phase);
      final d2 = 0.020 * cos(3 * angle - phase);
      final d3 = 0.012 * sin(4 * angle + 2 * phase);

      // Elastic elongation along drag angle and contraction along perpendicular
      final angleDiff = angle - dragAngle;
      final elongation = dragStretch * cos(2 * angleDiff);

      final r =
          baseRadius * (1.0 + (d1 + d2 + d3) * perturbationScale + elongation);

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      points.add(Offset(x, y));
    }

    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0].dx, points[0].dy);

    // Convert circular closed points to smooth cubic Beziers via Catmull-Rom
    for (int i = 0; i < segments; i++) {
      final p0 = points[(i - 1 + segments) % segments];
      final p1 = points[i];
      final p2 = points[(i + 1) % segments];
      final p3 = points[(i + 2) % segments];

      // Catmull-Rom to Cubic Bezier control points
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6.0,
        p1.dy + (p2.dy - p0.dy) / 6.0,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6.0,
        p2.dy - (p3.dy - p1.dy) / 6.0,
      );

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant IridescentBubblePainter oldDelegate) {
    return oldDelegate.fluidPhase != fluidPhase ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.dragStretch != dragStretch ||
        oldDelegate.dragAngle != dragAngle;
  }
}
