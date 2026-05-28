import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'app.dart';
import 'providers/song_providers.dart';
import 'services/music_handler.dart';

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

  MusicHandler handler;

  try {
    handler = await AudioService.init<MusicHandler>(
      builder: () => MusicHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.melophile.melophile.channel.audio',
        androidNotificationChannelName: 'Melophile Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'mipmap/launcher_icon',
      ),
    );
    debugPrint('AudioService initialized with notification');
  } catch (e, stack) {
    debugPrint('AudioService init failed, using fallback: $e');
    debugPrint(stack.toString());
    handler = MusicHandler();
  }

  runApp(
    ProviderScope(
      overrides: [
        audioServiceProvider.overrideWithValue(handler),
      ],
      child: const MelophileApp(),
    ),
  );
}
