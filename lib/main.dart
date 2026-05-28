import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'app.dart';
import 'providers/song_providers.dart';
import 'services/audio_service.dart';

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

  final player = AudioPlayer();
  final oldPlatform = JustAudioPlatform.instance;

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.melophile.melophile.channel.audio',
      androidNotificationChannelName: 'Melophile Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    );
    debugPrint('JustAudioBackground initialized with notification support');
  } catch (e) {
    JustAudioPlatform.instance = oldPlatform;
    debugPrint('JustAudioBackground failed (notification disabled): $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        audioServiceProvider.overrideWithValue(AudioPlayerService(player)),
      ],
      child: const MelophileApp(),
    ),
  );
}
