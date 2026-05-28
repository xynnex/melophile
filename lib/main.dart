import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Critical Initialization: Hive
    // We MUST wait for Hive to be ready as the app depends on it for data.
    // Removing timeout to ensure boxes are fully open before UI/Providers start.
    await Hive.initFlutter();
    
    // Open boxes sequentially for stability
    await Hive.openBox('settings');
    await Hive.openBox('songs');
    await Hive.openBox('favorites');
    await Hive.openBox('history');
    
    debugPrint('Hive initialized successfully with all boxes open');

    // 2. Secondary Initialization: JustAudioBackground
    // Critical for background playback - keeps foreground service alive
    // No timeout: partial init leaves _audioHandler unset, causing LateInitializationError on play
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.melophile.melophile.channel.audio',
      androidNotificationChannelName: 'Melophile Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    );
  } catch (e, stack) {
    debugPrint('Critical initialization error: $e');
    debugPrint(stack.toString());
    // Optionally: show a basic error UI if Hive fails completely
  }

  runApp(
    const ProviderScope(
      child: MelophileApp(),
    ),
  );
}
