import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingScreen extends StatefulWidget {
  final String exerciseName;
  const BreathingScreen({super.key, this.exerciseName = "Box Breathing"});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _fluidController;
  late AnimationController _springController;
  late AnimationController _resetController;
  Animation<Offset>? _springAnimation;
  Animation<double>? _resetScaleAnimation;
  Animation<Offset>? _resetOffsetAnimation;

  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  double _dragStretch = 0.0;
  bool _isPlaying = false;
  int _completedCycles = 0;
  double _lastBreathProgress = 0.0;

  final int cycleDurationSeconds = 16; // 4s inhale, 4s hold, 4s exhale, 4s hold

  @override
  void initState() {
    super.initState();

    // 16-second breathing cycle controller
    _breathingController =
        AnimationController(
          vsync: this,
          duration: Duration(seconds: cycleDurationSeconds),
        )..addListener(() {
          final currentVal = _breathingController.value;
          // Seamless cycle increment when repeating without frame drops
          if (_isPlaying && currentVal < _lastBreathProgress - 0.5) {
            setState(() {
              _completedCycles++;
            });
          }
          _lastBreathProgress = currentVal;
        });

    // Continuous fluid wobble & wave animation controller
    _fluidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Smooth reset controller to return bubble directly to resting state
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Spring controller for bouncy drag release & tap response
    _springController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addListener(() {
          if (_springAnimation != null) {
            setState(() {
              _dragOffset = _springAnimation!.value;
              _dragStretch =
                  (_dragOffset.distance / 120.0).clamp(0.0, 0.35) *
                  (1.0 - _springController.value);
              if (_dragOffset.distance > 0.01) {
                _dragAngle = atan2(_dragOffset.dy, _dragOffset.dx);
              }
            });
          }
        });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fluidController.dispose();
    _springController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isPlaying) return;
    _springController.stop();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isPlaying) return;
    setState(() {
      final raw = _dragOffset + details.delta;
      final dist = raw.distance;
      const maxDrag = 140.0;
      // Damped elastic drag distance
      final dampedDist = maxDrag * (1 - exp(-dist / maxDrag));
      _dragOffset = dist > 0 ? (raw / dist) * dampedDist : Offset.zero;
      _dragAngle = atan2(_dragOffset.dy, _dragOffset.dx);
      _dragStretch = (_dragOffset.distance / maxDrag).clamp(0.0, 0.35);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isPlaying) return;
    HapticFeedback.mediumImpact();
    _springAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
        );
    _springController.forward(from: 0.0);
  }

  void _onPanCancel() {
    if (_isPlaying) return;
    _onPanEnd(DragEndDetails());
  }

  void _onOrbTap() {
    if (_isPlaying) return;
    HapticFeedback.lightImpact();
    _springController.stop();
    _springAnimation =
        Tween<Offset>(begin: const Offset(0, -16), end: Offset.zero).animate(
          CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
        );
    _springController.forward(from: 0.0);
  }

  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
    _resetController.stop();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _springController.stop();
        _dragOffset = Offset.zero;
        _dragStretch = 0.0;
        _dragAngle = 0.0;
        _breathingController.repeat();
      } else {
        _breathingController.stop();
      }
    });
  }

  void _resetExercise() {
    HapticFeedback.mediumImpact();

    // Capture visual starting state for smooth, direct return
    final double startScale =
        _resetController.isAnimating && _resetScaleAnimation != null
            ? _resetScaleAnimation!.value
            : _getBreathingScale(_breathingController.value);
    final Offset startOffset =
        _resetController.isAnimating && _resetOffsetAnimation != null
            ? _resetOffsetAnimation!.value
            : _dragOffset;

    // Immediately stop ongoing cycle and reset timer to beginning
    _breathingController.stop();
    _breathingController.reset();
    _springController.stop();

    setState(() {
      _isPlaying = false;
      _completedCycles = 0;
      _dragOffset = Offset.zero;
      _dragStretch = 0.0;
      _dragAngle = 0.0;
      _lastBreathProgress = 0.0;
    });

    // Directly interpolate scale back to resting baseline 0.85 and offset to zero
    _resetScaleAnimation = Tween<double>(
      begin: startScale,
      end: 0.85,
    ).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _resetOffsetAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );

    _resetController.forward(from: 0.0);
  }

  String _getPhaseText(double value) {
    if (value < 0.25) return "Inhale";
    if (value < 0.50) return "Hold";
    if (value < 0.75) return "Exhale";
    return "Hold";
  }

  String _getPhaseInstruction(double value) {
    if (value < 0.25) return "Deeply through your nose";
    if (value < 0.50) return "Keep the breath still";
    if (value < 0.75) return "Slowly through your mouth";
    return "Relax and reset";
  }

  int _getPhaseSecondsRemaining(double value) {
    final phaseProgress = (value % 0.25) / 0.25;
    final remaining = 4 - (phaseProgress * 4).floor();
    return remaining.clamp(1, 4);
  }

  /// Calculates the dynamic scale of the bubble for breathing:
  /// - Inhale (0.0 to 0.25): Smooth expansion from 0.85 to 1.15
  /// - Hold (0.25 to 0.50): Suspended at peak size 1.15 with subtle micro-float
  /// - Exhale (0.50 to 0.75): Smooth contraction from 1.15 to 0.85
  /// - Hold (0.75 to 1.00): Resting state at 0.85
  double _getBreathingScale(double progress) {
    if (progress < 0.25) {
      final t = Curves.easeInOutCubic.transform(progress / 0.25);
      return 0.85 + 0.30 * t;
    } else if (progress < 0.50) {
      final holdT = (progress - 0.25) / 0.25;
      // Smooth C1-continuous micro-suspension with zero velocity at entry and exit
      final float = 0.5 * (1.0 - cos(holdT * 2 * pi));
      return 1.15 + 0.015 * float;
    } else if (progress < 0.75) {
      final t = Curves.easeInOutCubic.transform((progress - 0.50) / 0.25);
      return 1.15 - 0.30 * t;
    } else {
      final restT = (progress - 0.75) / 0.25;
      // Smooth C1-continuous micro-rest with zero velocity at entry and exit
      final float = 0.5 * (1.0 - cos(restT * 2 * pi));
      return 0.85 - 0.010 * float;
    }
  }

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableSize = min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final orbDimension = (availableSize * 0.70).clamp(180.0, 290.0);

              return AnimatedBuilder(
                animation: Listenable.merge([
                  _breathingController,
                  _fluidController,
                  _springController,
                  _resetController,
                ]),
                builder: (context, child) {
                  final breathProgress = _breathingController.value;
                  final fluidPhase = _fluidController.value;
                  // Continuous organic ambient breath pulse (always in motion even when idle)
                  final ambientBreath = 0.012 * sin(fluidPhase * 2 * pi);
                  final baseScale =
                      _resetController.isAnimating && _resetScaleAnimation != null
                          ? _resetScaleAnimation!.value
                          : _getBreathingScale(breathProgress);
                  final currentScale = baseScale + ambientBreath;
                  final effectiveOffset =
                      _resetController.isAnimating && _resetOffsetAnimation != null
                          ? _resetOffsetAnimation!.value
                          : _dragOffset;
                  final isAtRest = _breathingController.value == 0.0 ||
                      _resetController.isAnimating;
                  final phase = _isPlaying
                      ? _getPhaseText(breathProgress)
                      : (isAtRest ? "Ready" : "Paused");
                  final secondsRemaining = _isPlaying
                      ? "${_getPhaseSecondsRemaining(breathProgress)}s"
                      : (isAtRest
                          ? "16s cycle"
                          : "${_getPhaseSecondsRemaining(breathProgress)}s");
                  final instruction = _isPlaying
                      ? _getPhaseInstruction(breathProgress)
                      : (isAtRest ? "Tap play to begin" : "Tap to resume");

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Exactly Centered Animating Bubble & Ambient Wave Ribbons
                      Center(
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Background Acoustic / Breath Frequency Wave Ribbons
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: BackgroundWavesPainter(
                                    animationValue: fluidPhase,
                                    breathProgress: breathProgress,
                                    isPlaying: _isPlaying,
                                    orbOffset: effectiveOffset,
                                  ),
                                ),
                              ),

                              // The Glowing Iridescent Organic Bubble (Responds to Touch & Drag when paused)
                              Transform.translate(
                                offset: effectiveOffset,
                                child: Transform.scale(
                                  scale: currentScale,
                                  child: IgnorePointer(
                                    ignoring: _isPlaying,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: _isPlaying ? null : _onPanStart,
                                      onPanUpdate: _isPlaying ? null : _onPanUpdate,
                                      onPanEnd: _isPlaying ? null : _onPanEnd,
                                      onPanCancel: _isPlaying ? null : _onPanCancel,
                                      onTap: _isPlaying ? null : _onOrbTap,
                                      child: SizedBox(
                                        width: orbDimension,
                                        height: orbDimension,
                                        child: CustomPaint(
                                          painter: IridescentBubblePainter(
                                            fluidPhase: fluidPhase,
                                            breathProgress: breathProgress,
                                            isPlaying: _isPlaying,
                                            dragStretch: _dragStretch,
                                            dragAngle: _dragAngle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Top Navigation Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Text(
                                widget.exerciseName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.more_horiz,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Status and Phase Indicator (Above the centered orb)
                      Positioned(
                        top: (constraints.maxHeight * 0.11).clamp(64.0, 116.0),
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              phase,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              instruction,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    secondsRemaining,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFB8C8FF,
                                      ).withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8B5CF6,
                                    ).withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFC084FC,
                                      ).withValues(alpha: 0.28),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.repeat_rounded,
                                        size: 13,
                                        color: Color(0xFFDDD6FE),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Completed: $_completedCycles",
                                        style: const TextStyle(
                                          color: Color(0xFFDDD6FE),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 4. Bottom Play/Pause & Reset Glass Control Buttons
                      Positioned(
                        bottom: 36,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glassmorphism Reset Button
                            BouncingResetButton(
                              enabled: _breathingController.value > 0.0 ||
                                  _completedCycles > 0 ||
                                  _isPlaying ||
                                  _dragOffset != Offset.zero ||
                                  _resetController.isAnimating,
                              onTap: _resetExercise,
                            ),
                            const SizedBox(width: 24),
                            // Main Play/Pause Button
                            BouncingPlayButton(
                              isPlaying: _isPlaying,
                              onTap: _togglePlayPause,
                            ),
                            const SizedBox(width: 24),
                            // Symmetrical spacer for exact center alignment
                            const SizedBox(
                              width: 52,
                              height: 52,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

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

/// Floating glassmorphism play/pause button with haptic feedback
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
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA855F7), // Radiant Violet
                    Color(0xFF06B6D4), // Electric Cyan
                    Color(0xFFFB7185), // Warm Sunset Coral
                  ],
                ),
              ),
              child: Icon(
                widget.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating glassmorphism reset button with elastic feedback
class BouncingResetButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled;

  const BouncingResetButton({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<BouncingResetButton> createState() => _BouncingResetButtonState();
}

class _BouncingResetButtonState extends State<BouncingResetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: isEnabled ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.35,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.03),
              border: Border.all(
                color: Colors.white.withValues(alpha: isEnabled ? 0.20 : 0.08),
                width: 1.2,
              ),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: const Center(
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

