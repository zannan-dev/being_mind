import 'package:flutter/material.dart';

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
    _controller = AnimationController(
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

  double _getScale(double value) {
    if (value < 0.25) {
      // Inhale: 0.5 -> 1.0 (0 to 0.25 of total time)
      return 0.5 + (value / 0.25) * 0.5;
    } else if (value < 0.50) {
      // Hold
      return 1.0;
    } else if (value < 0.75) {
      // Exhale: 1.0 -> 0.5 (0.50 to 0.75 of total time)
      return 1.0 - ((value - 0.50) / 0.25) * 0.5;
    } else {
      // Hold
      return 0.5;
    }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings,
                          color: Colors.white, size: 24),
                    )
                  ],
                ),
              ),

              const Spacer(),

              // Central Animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final value = _controller.value;
                  final scale = _getScale(value);
                  final phaseText = _getPhaseText(value);

                  return Column(
                    children: [
                      Text(
                        "4 seconds",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background glass circle
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                            ),
                            // Pulsating core
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.white.withOpacity(0.2),
                                    ],
                                    stops: const [0.2, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // Circular Progress
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 4,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF8C64F5)),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            // Phase Text
                            Text(
                              _isPlaying ? phaseText : "Ready",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8C64F5).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
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
                                colors: [
                                  Color(0xFFA084E8),
                                  Color(0xFF8C64F5),
                                ],
                              ),
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
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
