import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heltigo/main.dart';
import 'package:heltigo/providers/theme_provider.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(HeltigoApp(themeProvider: ThemeProvider()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
