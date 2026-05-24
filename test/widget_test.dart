import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:melophile/app.dart';
import 'package:melophile/providers/song_provider.dart';

void main() {
  testWidgets('App renders with Melophile title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SongProvider(),
        child: const MelophileApp(),
      ),
    );
    expect(find.text('Melophile'), findsNothing);
  });
}
