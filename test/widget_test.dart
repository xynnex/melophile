import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melophile/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MelophileApp(),
      ),
    );

    // Verify that our app starts.
    expect(find.byType(MelophileApp), findsOneWidget);
  });
}
