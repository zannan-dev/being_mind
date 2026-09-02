import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:being_mind/widgets/bouncing_wrapper.dart';

class BreathingScreen extends StatefulWidget {
  final String exerciseName;
  const BreathingScreen({super.key, this.exerciseName = "Box Breathing"});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  final int cycleDurationSeconds = 16;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(seconds: cycleDurationSeconds),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.repeat();
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  String _getPhaseText(double value) {
    if (value < 0.25) return "Inhale";
    if (value < 0.50) return "Hold";
    if (value < 0.75) return "Exhale";
    return "Hold";
  }

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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Central Dial Area
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final value = _controller.value;
                  final phaseText = _isPlaying ? _getPhaseText(value) : "Ready";

                  return BouncingWrapper(
                    scaleDown: 0.04,
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Custom Painted Dial inside a styled Container
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8C64F5,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: BreathingDialPainter(progress: value),
                            ),
                          ),

                          // Centered Content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                phaseText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),
              const SizedBox(height: 32),

              // Bottom Navigation / Play Button Area
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Bottom spacer to keep play button position
                  const SizedBox(height: 80, width: double.infinity),
                  Positioned(
                    bottom: 30,
                    child: BouncingPlayButton(
                      isPlaying: _isPlaying,
                      onTap: _togglePlayPause,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreathingDialPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  BreathingDialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Middle dotted ring
    final dottedRingRadius = radius - 30;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final int numDots = 36;
    for (int i = 0; i < numDots; i++) {
      final angle = (i * 2 * pi) / numDots;
      final x = center.dx + dottedRingRadius * cos(angle);
      final y = center.dy + dottedRingRadius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    // 4 Phase Markers on the dotted ring
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Position markers at top, right, bottom, left (angles: -pi/2, 0, pi/2, pi)
    final List<double> markerAngles = [-pi / 2, 0, pi / 2, pi];
    for (var angle in markerAngles) {
      final x = center.dx + dottedRingRadius * cos(angle);
      final y = center.dy + dottedRingRadius * sin(angle);
      canvas.drawCircle(Offset(x, y), 8.0, markerPaint);
    }

    // Inner progress track (faint)
    final trackRadius = radius - 70;
    final trackPaint = Paint()
      ..color = const Color(0xFF907FEF).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, trackRadius, trackPaint);

    // Active progress arc
    final sweepAngle = 2 * pi * progress;

    if (sweepAngle > 0) {
      // Glow effect for the progress arc
      final arcGlowPaint = Paint()
        ..color = const Color(0xFF7A6DF4).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 16.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: trackRadius),
        -pi / 2,
        sweepAngle,
        false,
        arcGlowPaint,
      );

      // Core solid progress arc
      final progressPaint = Paint()
        ..color =
            const Color(0xFF7A6DF4) // vibrant purple
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: trackRadius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Thumb / Handle
      final thumbAngle = -pi / 2 + sweepAngle;
      final thumbX = center.dx + trackRadius * cos(thumbAngle);
      final thumbY = center.dy + trackRadius * sin(thumbAngle);

      // Glow effect for the thumb
      final thumbGlowPaint = Paint()
        ..color = const Color(0xFF7A6DF4).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(Offset(thumbX, thumbY), 18.0, thumbGlowPaint);

      // Core solid thumb
      final thumbPaint = Paint()
        ..color = const Color(0xFF7A6DF4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(thumbX, thumbY), 10.0, thumbPaint);
    }

    // Background gradient for the dial center
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: trackRadius));
    canvas.drawCircle(center, trackRadius, bgPaint);
  }

  @override
  bool shouldRepaint(covariant BreathingDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class BouncingPlayButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isPlaying;

  const BouncingPlayButton({
    super.key,
    required this.onTap,
    required this.isPlaying,
  });

  @override
  State<BouncingPlayButton> createState() => _BouncingPlayButtonState();
}

class _BouncingPlayButtonState extends State<BouncingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    HapticFeedback.mediumImpact();
    _controller.reverse();
    widget.onTap();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8C64F5).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFA084E8), Color(0xFF8C64F5)],
                ),
              ),
              child: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
