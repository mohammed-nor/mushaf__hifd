// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_hifd/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  testWidgets('Random Thomun generator and navigation smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that Recite tab is present and selected.
    expect(find.text('تلاوة'), findsOneWidget);
    expect(find.text('لم يتم اختيار ثمن بعد'), findsOneWidget);

    // Tap the shuffle button and trigger a frame.
    await tester.tap(find.byIcon(Icons.shuffle));
    await tester
        .pump(); // We use pump instead of pumpAndSettle to not wait on images

    // Verify that a thomun has been selected.
    expect(find.text('لم يتم اختيار ثمن بعد'), findsNothing);
    expect(find.byType(Image), findsWidgets); // Can be multiple due to UI

    // Tap the Learn tab
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester
        .pump(); // We use pump instead of pumpAndSettle to not wait on images

    // Verify Learn page is shown
    expect(find.text('إحفظ : 1-0-1'), findsOneWidget);

    // PageView preloads some images
    expect(find.byType(Image), findsWidgets);

    // Tap the Learn2 (text) tab
    await tester.tap(find.byIcon(Icons.text_snippet));
    await tester.pump();

    // Verify Learn2 page is shown
    expect(find.text('إحفظ نص : 1-0'), findsOneWidget);

    // Tap the Settings tab
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings page is shown
    expect(find.text('مصحف الحفظ - ورش مثمن'), findsOneWidget);
    expect(find.text('حقوق النشر'), findsOneWidget);
  });
}
