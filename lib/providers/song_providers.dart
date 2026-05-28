import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/file_scanner_service.dart';
import '../services/persistence_service.dart';

// 1. Service Providers
final audioServiceProvider = Provider((ref) => AudioService());
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
  final AudioService _audioService;
  final PersistenceService _persistenceService;
  Timer? _sleepTimer;

  PlaybackNotifier(this._audioService, this._persistenceService) : super(PlaybackState()) {
    _init();
  }

  void _init() {
    _audioService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _audioService.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
    _audioService.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
    });
  }

  void _onTrackComplete() {
    if (state.repeatMode == RepeatMode.one) {
      _audioService.seek(Duration.zero);
      _audioService.resume();
    } else {
      nextSong(state.activePlaylist);
    }
  }

  Future<void> play(Song song, {List<Song>? playlist}) async {
    await _audioService.play(song);
    state = state.copyWith(
      currentSong: song,
      activePlaylist: playlist ?? state.activePlaylist,
    );
    await _persistenceService.addToHistory(song);
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  void seek(Duration pos) => _audioService.seek(pos);

  void toggleShuffle() {
    state = state.copyWith(isShuffled: !state.isShuffled);
  }

  void cycleRepeatMode() {
    final nextMode = RepeatMode.values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
    _audioService.setLoopMode(nextMode == RepeatMode.one ? LoopMode.one : LoopMode.off);
  }

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    state = state.copyWith(sleepTimerDuration: duration, isSleepTimerActive: true);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sleepTimerDuration!.inSeconds > 0) {
        state = state.copyWith(sleepTimerDuration: state.sleepTimerDuration! - const Duration(seconds: 1));
      } else {
        _audioService.stop();
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
    await _audioService.stop();
    state = state.copyWith(currentSong: null, isPlaying: false);
  }

  void nextSong([List<Song>? songs]) {
    final list = songs ?? state.activePlaylist;
    if (list.isEmpty) return;
    int index = list.indexWhere((s) => s.id == state.currentSong?.id);
    int nextIndex;

    if (state.isShuffled) {
      nextIndex = Random().nextInt(list.length);
    } else {
      nextIndex = index + 1;
    }

    if (nextIndex >= list.length) {
      if (state.repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        stop();
        return;
      }
    }
    play(list[nextIndex]);
  }

  void previousSong([List<Song>? songs]) {
    final list = songs ?? state.activePlaylist;
    if (list.isEmpty) return;
    if (state.position > const Duration(seconds: 3)) {
      _audioService.seek(Duration.zero);
      return;
    }

    int index = list.indexWhere((s) => s.id == state.currentSong?.id);
    int prevIndex = index - 1;

    if (prevIndex < 0) {
      if (state.repeatMode == RepeatMode.all) {
        prevIndex = list.length - 1;
      } else {
        prevIndex = 0;
      }
    }
    play(list[prevIndex]);
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
      final songs = _persistence.getSongs();
      state = songs;
      _isInitialized = true;
      debugPrint('SongsNotifier: Initialized with ${state.length} songs');
    } catch (e) {
      debugPrint('SongsNotifier: Init error: $e');
      _isInitialized = true; // Still mark as initialized to allow recovery
    }
  }

  Future<void> scanFolder() async {
    if (!_isInitialized) {
      debugPrint('SongsNotifier: Waiting for initialization...');
      return;
    }
    final newSongs = await _scanner.scanSelectedDirectory();
    await _addUniqueSongs(newSongs);
  }

  Future<void> scanDefault() async {
    if (!_isInitialized) {
      debugPrint('SongsNotifier: Waiting for initialization...');
      return;
    }
    final newSongs = await _scanner.scanDefaultDirectories();
    await _addUniqueSongs(newSongs);
  }

  Future<void> _addUniqueSongs(List<Song> newSongs) async {
    if (newSongs.isEmpty) return;

    final currentPaths = state.map((s) => s.filePath).toSet();
    final uniqueNew = newSongs.where((s) => !currentPaths.contains(s.filePath)).toList();
    
    if (uniqueNew.isNotEmpty) {
      debugPrint('SongsNotifier: Adding ${uniqueNew.length} new songs');
      state = [...state, ...uniqueNew];
      await _persistence.saveSongs(state);
    } else {
      debugPrint('SongsNotifier: No new unique songs found');
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
