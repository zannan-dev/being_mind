import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

part 'breathing_provider.g.dart';

class BreathingSessionState {
  final int targetCycles;
  final int completedCycles;
  final bool isPlaying;
  final bool isPreparing;
  final int prepSecondsRemaining;

  BreathingSessionState({
    required this.targetCycles,
    required this.completedCycles,
    required this.isPlaying,
    required this.isPreparing,
    required this.prepSecondsRemaining,
  });

  BreathingSessionState copyWith({
    int? targetCycles,
    int? completedCycles,
    bool? isPlaying,
    bool? isPreparing,
    int? prepSecondsRemaining,
  }) {
    return BreathingSessionState(
      targetCycles: targetCycles ?? this.targetCycles,
      completedCycles: completedCycles ?? this.completedCycles,
      isPlaying: isPlaying ?? this.isPlaying,
      isPreparing: isPreparing ?? this.isPreparing,
      prepSecondsRemaining: prepSecondsRemaining ?? this.prepSecondsRemaining,
    );
  }
}

@riverpod
class BreathingSession extends _$BreathingSession {
  Timer? _prepTimer;
  late Duration _startDelay;

  @override
  BreathingSessionState build({
    required int defaultTargetCycles,
    required Duration startDelay,
  }) {
    _startDelay = startDelay;

    ref.onDispose(() {
      _prepTimer?.cancel();
    });

    return BreathingSessionState(
      targetCycles: defaultTargetCycles,
      completedCycles: 0,
      isPlaying: false,
      isPreparing: false,
      prepSecondsRemaining: startDelay.inSeconds,
    );
  }

  void togglePlayPause() {
    // If tapped during preparation countdown, cancel preparation
    if (state.isPreparing) {
      _prepTimer?.cancel();
      state = state.copyWith(isPreparing: false, isPlaying: false);
      return;
    }

    if (state.isPlaying) {
      // Pause
      state = state.copyWith(isPlaying: false);
    } else {
      // Starting from beginning or after completion
      if (state.completedCycles >= state.targetCycles) {
        state = state.copyWith(completedCycles: 0);
        if (_startDelay > Duration.zero) {
          startPreparation();
        } else {
          startExerciseNow();
        }
      } else {
        // Resuming paused breath mid-cycle
        startExerciseNow();
      }
    }
  }

  void startPreparation() {
    _prepTimer?.cancel();
    state = state.copyWith(
      isPreparing: true,
      prepSecondsRemaining: _startDelay.inSeconds,
    );

    _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.prepSecondsRemaining > 1) {
        state = state.copyWith(
          prepSecondsRemaining: state.prepSecondsRemaining - 1,
        );
      } else {
        timer.cancel();
        startExerciseNow();
      }
    });
  }

  void startExerciseNow() {
    _prepTimer?.cancel();
    state = state.copyWith(
      isPreparing: false,
      isPlaying: true,
    );
  }

  void resetExercise() {
    _prepTimer?.cancel();
    state = state.copyWith(
      isPreparing: false,
      isPlaying: false,
      completedCycles: 0,
    );
  }

  void incrementCycle() {
    final nextCycles = state.completedCycles + 1;
    if (nextCycles >= state.targetCycles) {
      state = state.copyWith(
        completedCycles: nextCycles,
        isPlaying: false,
      );
    } else {
      state = state.copyWith(completedCycles: nextCycles);
    }
  }

  void cycleTargetCycles() {
    int nextTarget = state.targetCycles;
    if (nextTarget == 4) {
      nextTarget = 8;
    } else if (nextTarget == 8) {
      nextTarget = 12;
    } else {
      nextTarget = 4;
    }
    state = state.copyWith(targetCycles: nextTarget);
  }
}
