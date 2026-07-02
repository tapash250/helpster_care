import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpster_care/app/app.dart';

void main() {
  testWidgets('HelpsterCareApp builds and shows the app title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HelpsterCareApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Helpster Care'), findsOneWidget);
  });
}
