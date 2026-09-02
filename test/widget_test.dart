import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:being_mind/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException ||
          details.exception.toString().contains('NetworkImageLoadException') ||
          details.exception.toString().contains('statusCode: 400')) {
        // Ignore network image exceptions during offline testing
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const BoxBreathingApp());
    expect(find.text('Exercises'), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
