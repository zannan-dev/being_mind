import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:being_mind/screens/breathing_screen.dart';
import 'package:being_mind/widgets/bouncing_play_button.dart';
import 'package:being_mind/widgets/bouncing_reset_button.dart';
import 'package:being_mind/painters/iridescent_bubble_painter.dart';

void main() {
  testWidgets('BreathingScreen renders iridescent bubble timer and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Verify exercise title and initial state
    expect(find.text('Box Breathing'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Tap play to begin'), findsOneWidget);
    expect(find.text('16s cycle'), findsOneWidget);

    // Verify play button is present
    expect(find.byType(BouncingPlayButton), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Tap play to start breathing exercise
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // During preparation delay, shows pause icon and "Get Ready"
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.text('Get Ready'), findsOneWidget);

    // Advance past preparation delay (3 seconds) to begin Inhale
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Inhale'), findsOneWidget);

    // Forward through breathing animation
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Hold'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Exhale'), findsOneWidget);
  });

  testWidgets('BreathingScreen bubble responds to touch and drag gestures',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Find the bubble CustomPaint widget
    final bubbleFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is IridescentBubblePainter,
    );
    expect(bubbleFinder, findsOneWidget);

    // Perform tap on the bubble
    await tester.tap(bubbleFinder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    // Perform drag gesture on the bubble
    final gesture = await tester.startGesture(tester.getCenter(bubbleFinder));
    await gesture.moveBy(const Offset(40, -30));
    await tester.pump();

    // Release gesture to trigger bouncy spring back
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Box Breathing'), findsOneWidget);
  });

  testWidgets(
      'BreathingScreen bubble drag and touch do not work when timer starts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Verify IgnorePointer ignoring is initially false
    final initialIgnorePointer = tester.widget<IgnorePointer>(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is IridescentBubblePainter,
        ),
        matching: find.byType(IgnorePointer),
      ).first,
    );
    expect(initialIgnorePointer.ignoring, isFalse);

    // Start the timer
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify IgnorePointer ignoring is now true
    final activeIgnorePointer = tester.widget<IgnorePointer>(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is IridescentBubblePainter,
        ),
        matching: find.byType(IgnorePointer),
      ).first,
    );
    expect(activeIgnorePointer.ignoring, isTrue);

    // Verify GestureDetector has null drag & tap callbacks when playing
    final gestureDetector = tester.widget<GestureDetector>(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is IridescentBubblePainter,
        ),
        matching: find.byType(GestureDetector),
      ).first,
    );
    expect(gestureDetector.onPanStart, isNull);
    expect(gestureDetector.onPanUpdate, isNull);
    expect(gestureDetector.onPanEnd, isNull);
    expect(gestureDetector.onPanCancel, isNull);
    expect(gestureDetector.onTap, isNull);

    // Pause the timer
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify gestures are re-enabled
    final pausedIgnorePointer = tester.widget<IgnorePointer>(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is IridescentBubblePainter,
        ),
        matching: find.byType(IgnorePointer),
      ).first,
    );
    expect(pausedIgnorePointer.ignoring, isFalse);

    final pausedGestureDetector = tester.widget<GestureDetector>(
      find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is IridescentBubblePainter,
        ),
        matching: find.byType(GestureDetector),
      ).first,
    );
    expect(pausedGestureDetector.onPanStart, isNotNull);
    expect(pausedGestureDetector.onPanUpdate, isNotNull);
    expect(pausedGestureDetector.onPanEnd, isNotNull);
    expect(pausedGestureDetector.onPanCancel, isNotNull);
    expect(pausedGestureDetector.onTap, isNotNull);
  });

  testWidgets(
      'BreathingScreen bubble scale does not abruptly jump when starting and stopping',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Helper to find the Transform.scale applied to the bubble
    double getBubbleScale() {
      final bubbleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is IridescentBubblePainter,
      );
      final transformWidgets = tester.widgetList<Transform>(
        find.ancestor(
          of: bubbleFinder,
          matching: find.byType(Transform),
        ),
      );
      for (final t in transformWidgets) {
        final sx = t.transform.storage[0];
        if ((sx - 1.0).abs() > 0.001) {
          return sx;
        }
      }
      return 1.0;
    }

    // Initial scale before starting
    final initialScale = getBubbleScale();
    expect(initialScale, closeTo(0.85, 0.01));

    // Tap play to start
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(); // Immediate frame after starting

    // Scale must not jump to 0.95 or away from 0.85
    final scaleImmediatelyAfterStart = getBubbleScale();
    expect(scaleImmediatelyAfterStart, closeTo(0.85, 0.01));

    // Progress a little bit through inhale (e.g. 1 second)
    await tester.pump(const Duration(seconds: 1));
    final scaleDuringInhale = getBubbleScale();
    expect(scaleDuringInhale, greaterThan(initialScale));

    // Tap pause to stop
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(); // Immediate frame after stopping

    // Scale must not suddenly jump to 0.95; it must remain at its current scale
    final scaleImmediatelyAfterStop = getBubbleScale();
    expect(scaleImmediatelyAfterStop, closeTo(scaleDuringInhale, 0.001));
  });

  testWidgets(
      'BreathingScreen tracks completed cycles and smoothly resets to normal position on reset tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    double getBubbleScale() {
      final bubbleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is IridescentBubblePainter,
      );
      final transformWidgets = tester.widgetList<Transform>(
        find.ancestor(
          of: bubbleFinder,
          matching: find.byType(Transform),
        ),
      );
      for (final t in transformWidgets) {
        final sx = t.transform.storage[0];
        if ((sx - 1.0).abs() > 0.001) {
          return sx;
        }
      }
      return 1.0;
    }

    // Verify initial cycle indicator and reset button
    expect(find.byType(BouncingResetButton), findsOneWidget);
    expect(find.text('Completed: 0'), findsOneWidget);
    expect(
      tester.widget<BouncingResetButton>(find.byType(BouncingResetButton)).enabled,
      isFalse,
    );

    // Tap play to start exercise
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // Reset button is now enabled
    expect(
      tester.widget<BouncingResetButton>(find.byType(BouncingResetButton)).enabled,
      isTrue,
    );

    // Advance through the cycle until completed
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(seconds: 1));
      if (find.text('Completed: 1').evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.text('Completed: 1'), findsOneWidget);

    // Progress into next cycle (Inhale peak at 4s)
    await tester.pump(const Duration(seconds: 4));
    expect(getBubbleScale(), closeTo(1.15, 0.05));

    // Tap reset button
    await tester.tap(find.byType(BouncingResetButton));
    await tester.pump();

    // Completed cycles reset immediately
    expect(find.text('Completed: 0'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Pump through smooth reset animation curve (650ms)
    await tester.pump(const Duration(milliseconds: 700));

    // Bubble scale has smoothly returned to normal resting position (0.85)
    expect(getBubbleScale(), closeTo(0.85, 0.01));
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets(
      'BreathingScreen reset works when tapped from paused state and resets labels immediately',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Start playing
    // Start exercise and advance past 3s prep delay into active breath
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));

    // Pause
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Paused'), findsOneWidget);

    // Tap reset while paused
    await tester.tap(find.byType(BouncingResetButton));
    await tester.pump();

    // Immediately shows Ready state
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Tap play to begin'), findsOneWidget);
    expect(find.text('16s cycle'), findsOneWidget);
    expect(find.text('Completed: 0'), findsOneWidget);

    // Advance reset animation
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets(
      'BreathingScreen maintains continuous movement without sudden jumps across loop boundaries',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    double getBubbleScale() {
      final transformFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Transform &&
            widget.transform.storage[0] != 1.0 &&
            widget.transform.storage[0] == widget.transform.storage[5],
      );
      final transformWidget = tester.widget<Transform>(transformFinder.first);
      return transformWidget.transform.storage[0];
    }

    // 1. In idle state, verify continued movement (ambient breath changes smoothly over 6s)
    final scaleAtT0 = getBubbleScale();
    await tester.pump(const Duration(milliseconds: 1500)); // Quarter fluid cycle (peak)
    final scaleAtT15 = getBubbleScale();
    expect((scaleAtT15 - scaleAtT0).abs(), greaterThan(0.005));

    // Complete the 6-second fluid cycle: scale returns smoothly without snap
    await tester.pump(const Duration(milliseconds: 4500));
    final scaleAtT60 = getBubbleScale();
    expect(scaleAtT60, closeTo(scaleAtT0, 0.002));

    // 2. During exercise, verify smooth continuity across phase transitions
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // Sample scale around the Inhale -> Hold transition (3.9s vs 4.1s)
    await tester.pump(const Duration(milliseconds: 3700));
    final scaleBeforeHold = getBubbleScale();
    await tester.pump(const Duration(milliseconds: 200));
    final scaleAtHold = getBubbleScale();
    await tester.pump(const Duration(milliseconds: 200));
    final scaleAfterHold = getBubbleScale();

    // The scale differences between consecutive 200ms frames are tiny and continuous (no sudden jump)
    expect((scaleAtHold - scaleBeforeHold).abs(), lessThan(0.04));
    expect((scaleAfterHold - scaleAtHold).abs(), lessThan(0.04));
  });

  testWidgets(
      'BreathingScreen displays fixed cycle count and toggles target cycles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: '4-7-8 Relaxing Breath'),
      ),
    );

    // Initial state: shows 19s cycle and target cycles / 4
    expect(find.text('19s cycle'), findsOneWidget);
    expect(find.text('Completed: 0'), findsOneWidget);
    expect(find.text(' / 4'), findsOneWidget);

    // Tapping the cycle badge when idle toggles target cycles (4 -> 8 -> 12)
    await tester.tap(find.text('Completed: 0'));
    await tester.pump();
    expect(find.text(' / 8'), findsOneWidget);
  });

  testWidgets(
      'BreathingScreen transitions text smoothly using AnimatedSwitcher',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Verify AnimatedSwitcher is used for status text elements
    expect(find.byType(AnimatedSwitcher), findsAtLeastNWidgets(3));

    // Start exercise and verify smooth transition into Get Ready
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 90)); // Mid-fade
    await tester.pump(const Duration(milliseconds: 150)); // Finished fade
    expect(find.text('Get Ready'), findsOneWidget);

    // Advance past preparation delay into Inhale
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Inhale'), findsOneWidget);
  });

  testWidgets(
      'BreathingScreen counts down preparation delay and can be cancelled before exercise starts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BreathingScreen(exerciseName: 'Box Breathing'),
      ),
    );

    // Initial state
    expect(find.text('Ready'), findsOneWidget);

    // Tap play to enter preparation delay
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));

    // Shows countdown 3s and "Get Ready"
    expect(find.text('Get Ready'), findsOneWidget);
    expect(find.text('3s'), findsOneWidget);

    // After 1 second, counts down to 2s
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2s'), findsOneWidget);

    // After another second, counts down to 1s
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1s'), findsOneWidget);

    // Tapping play/pause during countdown cancels preparation and returns to Ready
    await tester.tap(find.byType(BouncingPlayButton));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('16s cycle'), findsOneWidget);
  });
}


