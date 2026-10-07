import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('switching language updates visible labels and text direction', (tester) async {
    await tester.pumpWidget(const SallihCustomerApp());
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.text('استكشاف النسخة التجريبية'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Explore the demo'), findsOneWidget);
    final context = tester.element(find.text('Explore the demo'));
    expect(Localizations.localeOf(context), const Locale('en'));
    expect(Directionality.of(context), TextDirection.ltr);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('language'), 'en');
  });

  testWidgets('saved language is restored and demo mode is labelled', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await tester.pumpWidget(const SallihCustomerApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore the demo'));
    await tester.tap(find.text('Explore the demo'));
    await tester.pumpAndSettle();
    expect(find.text('Demo mode • sample data'), findsWidgets);
    expect(find.text('Explore services'), findsOneWidget);
    expect(find.textContaining('Verified via Nafath'), findsNothing);
  });
}
