import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_demo_1/main.dart';
import 'package:flutter_demo_1/features/auth/splash_screen.dart';

void main() {
  testWidgets('App starts at Splash and logic exists', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnchorApp());

    // Verify that the Splash Screen is present initially.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Anchor'), findsOneWidget);
  });
}
