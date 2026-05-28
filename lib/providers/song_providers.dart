import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';
import '../services/music_handler.dart';
import '../services/file_scanner_service.dart';
import '../services/persistence_service.dart';

// 1. Service Providers
final audioServiceProvider = Provider<MusicHandler>((ref) => throw UnimplementedError('Must be overridden in main()'));
final fileScannerServiceProvider = Provider((ref) => FileScannerService());
final persistenceServiceProvider = Provider((ref) => PersistenceService());

// 2. Playback State Model
class PlaybackState {
  final Song? currentSong;
  final List<Song> activePlaylist;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final Duration? sleepTimerDuration;
  final bool isSleepTimerActive;

  PlaybackState({
    this.currentSong,
    this.activePlaylist = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.none,
    this.sleepTimerDuration,
    this.isSleepTimerActive = false,
  });

  PlaybackState copyWith({
    Song? currentSong,
    List<Song>? activePlaylist,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    RepeatMode? repeatMode,
    Duration? sleepTimerDuration,
    bool? isSleepTimerActive,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      activePlaylist: activePlaylist ?? this.activePlaylist,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
    );
  }
}

enum RepeatMode { none, all, one }

// 3. Playback Notifier
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final MusicHandler _audioHandler;
  final PersistenceService _persistenceService;
  Timer? _sleepTimer;

  PlaybackNotifier(this._audioHandler, this._persistenceService) : super(PlaybackState()) {
    _init();
  }

  void _init() {
    // Sync with audio handler's mediaItem (for song changes triggered by system)
    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        final song = state.activePlaylist.firstWhere(
          (s) => s.id.toString() == item.id,
          orElse: () => Song(
            id: int.tryParse(item.id) ?? -1,
            title: item.title,
            artist: item.artist ?? 'Unknown Artist',
            filePath: '',
          ),
        );
        state = state.copyWith(currentSong: song);
      }
    });

    _audioHandler.playbackState.listen((playbackState) {
      state = state.copyWith(
        isPlaying: playbackState.playing,
        position: playbackState.updatePosition,
      );
    });

    _audioHandler.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
  }

  Future<void> play(Song song, {List<Song>? playlist}) async {
    final list = playlist ?? state.activePlaylist;
    
    // Check if playlist is already active and just seek
    int index = list.indexWhere((s) => s.id == song.id);
    if (index == -1) index = 0;

    // We still update the local state for immediate UI feedback
    state = state.copyWith(
      currentSong: song,
      activePlaylist: list,
    );

    await _audioHandler.setPlaylist(list, initialIndex: index);
    await _audioHandler.play();
    await _persistenceService.addToHistory(song);
  }

  Future<void> togglePlayPause() async {
    await _audioHandler.togglePlayPause();
  }

  void seek(Duration pos) => _audioHandler.seek(pos);

  void toggleShuffle() {
    final newState = !state.isShuffled;
    state = state.copyWith(isShuffled: newState);
    _audioHandler.setShuffleMode(
      newState ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  void cycleRepeatMode() {
    final nextMode = RepeatMode.values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
    
    LoopMode justAudioMode;
    switch (nextMode) {
      case RepeatMode.one:
        justAudioMode = LoopMode.one;
        break;
      case RepeatMode.all:
        justAudioMode = LoopMode.all;
        break;
      case RepeatMode.none:
        justAudioMode = LoopMode.off;
        break;
    }
    _audioHandler.setLoopMode(justAudioMode);
  }

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    state = state.copyWith(sleepTimerDuration: duration, isSleepTimerActive: true);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sleepTimerDuration!.inSeconds > 0) {
        state = state.copyWith(sleepTimerDuration: state.sleepTimerDuration! - const Duration(seconds: 1));
      } else {
        _audioHandler.stop();
        cancelSleepTimer();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(sleepTimerDuration: null, isSleepTimerActive: false);
  }

  Future<void> stop() async {
    await _audioHandler.stop();
    state = state.copyWith(currentSong: null, isPlaying: false);
  }

  void nextSong() {
    _audioHandler.skipToNext();
  }

  void previousSong() {
    if (state.position > const Duration(seconds: 3)) {
      _audioHandler.seek(Duration.zero);
      return;
    }
    _audioHandler.skipToPrevious();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(ref.watch(audioServiceProvider), ref.watch(persistenceServiceProvider));
});

// 4. Songs Notifier
class SongsNotifier extends StateNotifier<List<Song>> {
  final FileScannerService _scanner;
  final PersistenceService _persistence;
  bool _isInitialized = false;

  SongsNotifier(this._scanner, this._persistence) : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      final savedSongs = _persistence.getSongs();
      if (savedSongs.isNotEmpty) {
        state = List<Song>.from(savedSongs);
        debugPrint('SongsNotifier: Successfully loaded ${state.length} songs from Hive');
      } else {
        debugPrint('SongsNotifier: No songs found in Hive storage');
      }
    } catch (e) {
      debugPrint('SongsNotifier: Critical init error: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> scanFolder() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final newSongs = await _scanner.scanSelectedDirectory();
    await _addUniqueSongs(newSongs);
  }

  Future<void> scanDefault() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final newSongs = await _scanner.scanDefaultDirectories();
    await _addUniqueSongs(newSongs);
  }

  Future<void> _addUniqueSongs(List<Song> newSongs) async {
    if (newSongs.isEmpty) return;

    final currentPaths = state.map((s) => s.filePath).toSet();
    final uniqueNew = newSongs.where((s) => !currentPaths.contains(s.filePath)).toList();
    
    if (uniqueNew.isNotEmpty) {
      final updatedList = [...state, ...uniqueNew];
      state = updatedList;
      // Save entire library to persist
      await _persistence.saveSongs(state);
      debugPrint('SongsNotifier: Library updated and saved. Total: ${state.length}');
    }
  }

  Future<void> clear() async {
    state = [];
    await _persistence.clearLibrary();
    debugPrint('SongsNotifier: Library cleared');
  }
}

final songsProvider = StateNotifierProvider<SongsNotifier, List<Song>>((ref) {
  return SongsNotifier(ref.watch(fileScannerServiceProvider), ref.watch(persistenceServiceProvider));
});

// 5. Favorites Notifier
class FavoritesNotifier extends StateNotifier<List<Song>> {
  final PersistenceService _persistence;

  FavoritesNotifier(this._persistence) : super([]) {
    state = _persistence.getFavorites();
  }

  Future<void> toggle(Song song) async {
    if (state.any((s) => s.id == song.id)) {
      state = state.where((s) => s.id != song.id).toList();
      await _persistence.removeFavorite(song.id);
    } else {
      state = [...state, song];
      await _persistence.saveFavorite(song);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Song>>((ref) {
  return FavoritesNotifier(ref.watch(persistenceServiceProvider));
});

// 6. History Provider (Simple)
final historyProvider = Provider((ref) {
  return ref.watch(persistenceServiceProvider).getHistory();
});
