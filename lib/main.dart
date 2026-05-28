import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('songs');
    await Hive.openBox('favorites');
    await Hive.openBox('history');
    debugPrint('Hive initialized successfully with all boxes open');
  } catch (e, stack) {
    debugPrint('Critical initialization error: $e');
    debugPrint(stack.toString());
  }

  runApp(
    const ProviderScope(
      child: MelophileApp(),
    ),
  );
}
