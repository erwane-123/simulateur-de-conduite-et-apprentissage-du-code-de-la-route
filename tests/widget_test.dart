import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:code_route_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
  
    await tester.pumpWidget(const MyApp());

  
    expect(find.byType(MaterialApp), findsOneWidget);
    
    
    expect(find.text('Tableau de bord'), findsOneWidget);
  });
}