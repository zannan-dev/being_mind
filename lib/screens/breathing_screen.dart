
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/breathing_provider.dart';
import '../widgets/bouncing_play_button.dart';
import '../widgets/bouncing_reset_button.dart';
import '../painters/background_waves_painter.dart';
import '../painters/iridescent_bubble_painter.dart';


class BreathingScreen extends ConsumerStatefulWidget {
  final String exerciseName;
  final Duration startDelay;

  const BreathingScreen({
    super.key,
    this.exerciseName = "Box Breathing",
    this.startDelay = const Duration(seconds: 3),
  });

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
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
  double _lastBreathProgress = 0.0;
  
  late FlutterTts _flutterTts;
  bool _isMuted = false;
  String _lastPhaseText = "";

  BreathingSessionProvider get _sessionProvider => breathingSessionProvider(
        defaultTargetCycles: defaultTargetCycles,
        startDelay: widget.startDelay,
      );

  int get cycleDurationSeconds {
    if (widget.exerciseName.contains('4-7-8')) return 19;
    if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      return 11;
    }
    return 16;
  }

  int get defaultTargetCycles {
    if (widget.exerciseName.contains('4-7-8')) return 4;
    if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      return 6;
    }
    return 4;
  }

  @override
  void initState() {
    super.initState();

    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.4);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    // Dynamic breathing cycle controller
    _breathingController =
        AnimationController(
          vsync: this,
          duration: Duration(seconds: cycleDurationSeconds),
        )..addListener(() {
          final currentVal = _breathingController.value;
          // Seamless cycle increment when repeating without frame drops
          final session = ref.read(_sessionProvider);
          
          if (session.isPlaying) {
             final currentPhaseText = _getPhaseText(currentVal);
             if (currentPhaseText != _lastPhaseText) {
                _lastPhaseText = currentPhaseText;
                
                if (currentPhaseText == "Inhale") {
                   // 1 Tap for Inhale
                   HapticFeedback.lightImpact();
                } else if (currentPhaseText == "Hold") {
                   // 2 Taps for Hold
                   HapticFeedback.selectionClick();
                   Future.delayed(const Duration(milliseconds: 200), () {
                     HapticFeedback.selectionClick();
                   });
                } else if (currentPhaseText == "Exhale") {
                   // 3 Taps for Exhale
                   HapticFeedback.heavyImpact();
                   Future.delayed(const Duration(milliseconds: 200), () {
                     HapticFeedback.heavyImpact();
                   });
                   Future.delayed(const Duration(milliseconds: 400), () {
                     HapticFeedback.heavyImpact();
                   });
                }
                
                if (!_isMuted) {
                   _flutterTts.speak(currentPhaseText);
                }
             }
          }
          
          if (session.isPlaying && currentVal < _lastBreathProgress - 0.5) {
            ref.read(_sessionProvider.notifier).incrementCycle();
            if (session.completedCycles + 1 >= session.targetCycles) {
              _breathingController.value = 0.0;
              _lastBreathProgress = 0.0;
              _lastPhaseText = "";
              if (!_isMuted) _flutterTts.speak("Session complete");
              HapticFeedback.heavyImpact();
            }
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
    _flutterTts.stop();
    _breathingController.dispose();
    _fluidController.dispose();
    _springController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (ref.read(_sessionProvider).isPlaying || ref.read(_sessionProvider).isPreparing) return;
    _springController.stop();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (ref.read(_sessionProvider).isPlaying || ref.read(_sessionProvider).isPreparing) return;
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
    if (ref.read(_sessionProvider).isPlaying || ref.read(_sessionProvider).isPreparing) return;
    HapticFeedback.mediumImpact();
    _springAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
        );
    _springController.forward(from: 0.0);
  }

  void _onPanCancel() {
    if (ref.read(_sessionProvider).isPlaying || ref.read(_sessionProvider).isPreparing) return;
    _onPanEnd(DragEndDetails());
  }

  void _onOrbTap() {
    if (ref.read(_sessionProvider).isPlaying || ref.read(_sessionProvider).isPreparing) return;
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
    
    final session = ref.read(_sessionProvider);
    if (!session.isPlaying && !session.isPreparing) {
      if (session.completedCycles == 0 && _breathingController.value == 0.0) {
        // Very first start
        ref.read(_sessionProvider.notifier).startPreparation();
        return;
      }
    }
    
    ref.read(_sessionProvider.notifier).togglePlayPause();
  }

  void _resetExercise() {
    HapticFeedback.mediumImpact();
    ref.read(_sessionProvider.notifier).resetExercise();

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
      _dragOffset = Offset.zero;
      _dragStretch = 0.0;
      _dragAngle = 0.0;
      _lastBreathProgress = 0.0;
      _lastPhaseText = "";
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
    if (widget.exerciseName.contains('4-7-8')) {
      if (value < 4.0 / 19.0) return "Inhale";
      if (value < 11.0 / 19.0) return "Hold";
      return "Exhale";
    } else if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      if (value < 0.50) return "Inhale";
      return "Exhale";
    } else {
      if (value < 0.25) return "Inhale";
      if (value < 0.50) return "Hold";
      if (value < 0.75) return "Exhale";
      return "Hold";
    }
  }

  String _getPhaseInstruction(double value) {
    if (widget.exerciseName.contains('4-7-8')) {
      if (value < 4.0 / 19.0) return "Inhale quietly through your nose";
      if (value < 11.0 / 19.0) return "Hold your breath calmly";
      return "Exhale fully through your mouth";
    } else if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      if (value < 0.50) return "Smooth, steady breath in";
      return "Gentle, effortless breath out";
    } else {
      if (value < 0.25) return "Deeply through your nose";
      if (value < 0.50) return "Keep the breath still";
      if (value < 0.75) return "Slowly through your mouth";
      return "Relax and reset";
    }
  }

  int _getPhaseSecondsRemaining(double value) {
    if (widget.exerciseName.contains('4-7-8')) {
      final t = value * 19.0;
      if (t < 4.0) return (4 - t.floor()).clamp(1, 4);
      if (t < 11.0) return (11 - t.floor()).clamp(1, 7);
      return (19 - t.floor()).clamp(1, 8);
    } else if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      final t = value * 11.0;
      if (t < 5.5) return (6 - t.floor()).clamp(1, 6);
      return (11 - t.floor()).clamp(1, 6);
    } else {
      final phaseProgress = (value % 0.25) / 0.25;
      final remaining = 4 - (phaseProgress * 4).floor();
      return remaining.clamp(1, 4);
    }
  }

  /// Calculates the dynamic scale of the bubble for breathing:
  /// - Box Breathing: 4-4-4-4
  /// - 4-7-8: 4s inhale, 7s hold, 8s exhale
  /// - Resonant Coherence: 5.5s inhale, 5.5s exhale
  double _getBreathingScale(double progress) {
    if (widget.exerciseName.contains('4-7-8')) {
      const inhaleEnd = 4.0 / 19.0;
      const holdEnd = 11.0 / 19.0;
      if (progress < inhaleEnd) {
        final t = Curves.easeInOutCubic.transform(progress / inhaleEnd);
        return 0.85 + 0.30 * t;
      } else if (progress < holdEnd) {
        final holdT = (progress - inhaleEnd) / (holdEnd - inhaleEnd);
        final float = 0.5 * (1.0 - cos(holdT * 2 * pi));
        return 1.15 + 0.015 * float;
      } else {
        final t = Curves.easeInOutCubic.transform(
          (progress - holdEnd) / (1.0 - holdEnd),
        );
        return 1.15 - 0.30 * t;
      }
    } else if (widget.exerciseName.contains('Resonant') ||
        widget.exerciseName.contains('Coherence')) {
      if (progress < 0.50) {
        final t = Curves.easeInOutCubic.transform(progress / 0.50);
        return 0.85 + 0.30 * t;
      } else {
        final t = Curves.easeInOutCubic.transform((progress - 0.50) / 0.50);
        return 1.15 - 0.30 * t;
      }
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_sessionProvider, (previous, next) {
      if (next.isPreparing && next.prepSecondsRemaining != previous?.prepSecondsRemaining) {
        HapticFeedback.selectionClick();
      }
      
      if (next.isPreparing && !(previous?.isPreparing ?? false)) {
        _springController.stop();
        setState(() {
          _dragOffset = Offset.zero;
          _dragStretch = 0.0;
          _dragAngle = 0.0;
        });
      }
      if (next.isPlaying && !(previous?.isPlaying ?? false)) {
        _springController.stop();
        setState(() {
          _dragOffset = Offset.zero;
          _dragStretch = 0.0;
          _dragAngle = 0.0;
          _lastPhaseText = ""; // reset phase on play
        });
        _breathingController.repeat();
      }
      if (!next.isPlaying && (previous?.isPlaying ?? false)) {
        _breathingController.stop();
      }
    });

    final session = ref.watch(_sessionProvider);

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
                  final isAtRest =
                      (_breathingController.value == 0.0 &&
                          !session.isPlaying &&
                          !session.isPreparing) ||
                      _resetController.isAnimating;
                  final isCompleted = session.completedCycles >= session.targetCycles;
                  final phase = session.isPreparing
                      ? "Get Ready"
                      : (isCompleted
                          ? "Complete"
                          : (session.isPlaying
                              ? _getPhaseText(breathProgress)
                              : (isAtRest ? "Ready" : "Paused")));
                  final secondsRemaining = session.isPreparing
                      ? "${session.prepSecondsRemaining}s"
                      : (session.isPlaying
                          ? "${_getPhaseSecondsRemaining(breathProgress)}s"
                          : (isAtRest
                              ? "${cycleDurationSeconds}s cycle"
                              : "${_getPhaseSecondsRemaining(breathProgress)}s"));
                  final instruction = session.isPreparing
                      ? "Settle in and relax your shoulders"
                      : (isCompleted
                          ? "Session completed! Tap to repeat"
                          : (session.isPlaying
                              ? _getPhaseInstruction(breathProgress)
                              : (isAtRest ? "Tap play to begin" : "Tap to resume")));

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
                                    isPlaying: session.isPlaying,
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
                                    ignoring: session.isPlaying || session.isPreparing,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: session.isPlaying || session.isPreparing
                                          ? null
                                          : _onPanStart,
                                      onPanUpdate: session.isPlaying || session.isPreparing
                                          ? null
                                          : _onPanUpdate,
                                      onPanEnd: session.isPlaying || session.isPreparing
                                          ? null
                                          : _onPanEnd,
                                      onPanCancel: session.isPlaying || session.isPreparing
                                          ? null
                                          : _onPanCancel,
                                      onTap: session.isPlaying || session.isPreparing
                                          ? null
                                          : _onOrbTap,
                                      child: SizedBox(
                                        width: orbDimension,
                                        height: orbDimension,
                                        child: CustomPaint(
                                          painter: IridescentBubblePainter(
                                            fluidPhase: fluidPhase,
                                            breathProgress: breathProgress,
                                            isPlaying: session.isPlaying,
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
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _isMuted = !_isMuted;
                                      });
                                    },
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _isMuted ? Icons.volume_off : Icons.volume_up,
                                        color: Colors.white70,
                                        size: 22,
                                      ),
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
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.12),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                phase,
                                key: ValueKey<String>(phase),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.12),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                instruction,
                                key: ValueKey<String>(instruction),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Pill 1: Stable, non-jumping cycle/countdown indicator
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 96,
                                      minHeight: 28,
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                      child: Text(
                                        secondsRemaining,
                                        key: ValueKey<String>(secondsRemaining),
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFB8C8FF,
                                          ).withValues(alpha: 0.9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Pill 2: Stable, non-jumping completed cycles badge
                                GestureDetector(
                                  onTap: session.isPlaying || session.isPreparing
                                      ? null
                                      : () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            ref.read(_sessionProvider.notifier).cycleTargetCycles();
                                          });
                                        },
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 152,
                                        minHeight: 28,
                                      ),
                                      alignment: Alignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.repeat_rounded,
                                            size: 13,
                                            color: Color(0xFFDDD6FE),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Completed: ${session.completedCycles}",
                                            style: const TextStyle(
                                              color: Color(0xFFDDD6FE),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.4,
                                              fontFeatures: [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            " / ${session.targetCycles}",
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFDDD6FE,
                                              ).withValues(alpha: 0.65),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                  session.completedCycles > 0 ||
                                  session.isPlaying ||
                                  session.isPreparing ||
                                  _dragOffset != Offset.zero ||
                                  _resetController.isAnimating,
                              onTap: _resetExercise,
                            ),
                            const SizedBox(width: 24),
                            // Main Play/Pause Button
                            BouncingPlayButton(
                              isPlaying: session.isPlaying || session.isPreparing,
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
