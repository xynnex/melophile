import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'providers/song_providers.dart';
import 'services/music_handler.dart';

Future<void> _requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  
  // Storage permissions for different Android versions
  await [
    Permission.audio,
    Permission.storage,
  ].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Audio Service FIRST
  MusicHandler handler;
  try {
    handler = await AudioService.init<MusicHandler>(
      builder: () => MusicHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.melophile.melophile.channel.audio',
        androidNotificationChannelName: 'Melophile Playback',
        androidNotificationChannelDescription: 'Music playback controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'mipmap/ic_notification',
        androidShowNotificationBadge: true,
        notificationColor: Color(0xFF2E7D32),
      ),
    );
    debugPrint('AudioService initialized successfully');
  } catch (e) {
    debugPrint('AudioService init failed: $e');
    handler = MusicHandler();
  }

  // 2. Request permissions
  await _requestPermissions();

  // 3. Initialize Hive
  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('songs');
    await Hive.openBox('favorites');
    await Hive.openBox('history');
  } catch (e) {
    debugPrint('Hive init error: $e');
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
