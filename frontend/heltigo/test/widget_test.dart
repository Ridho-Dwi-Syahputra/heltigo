import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heltigo/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HeltigoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
