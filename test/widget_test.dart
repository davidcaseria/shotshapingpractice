import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shotshapingpractice/main.dart';

void main() {
  testWidgets('Check menu', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Warm Up'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('View Stats'), findsOneWidget);

    //await tester.tap(find.byIcon(Icons.add));
    //await tester.pump();
  });
}
