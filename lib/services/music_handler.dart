import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  Song? _currentSong;
  final _volumeController = StreamController<double>.broadcast();
  
  void Function()? onSkipToNextCall;
  void Function()? onSkipToPreviousCall;

  MusicHandler() {
    _init();
  }

  Future<void> _init() async {
    debugPrint('MusicHandler: Initializing AudioSession...');
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Initial state to satisfy Android
    playbackState.add(PlaybackState(
      controls: [MediaControl.play],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    // Handle audio interruptions (phone calls, etc.)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            play();
            break;
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
        }
      }
    });

    // Listen to player state changes
    _player.playbackEventStream.listen(_onPlaybackEvent);
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen(_onPositionChanged);
    _player.durationStream.listen(_onDurationChanged);
    _player.volumeStream.listen((v) => _volumeController.add(v));
    debugPrint('MusicHandler: Initialization complete');
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    _updatePlaybackState();
  }

  void _onPlayerStateChanged(PlayerState state) {
    _updatePlaybackState();
    if (state.processingState == ProcessingState.completed) {
      skipToNext();
    }
  }

  void _onPositionChanged(Duration position) {
    _updatePlaybackState();
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null && _currentSong != null) {
      mediaItem.add(MediaItem(
        id: _currentSong!.id.toString(),
        title: _currentSong!.title,
        artist: _currentSong!.artist,
        album: _currentSong!.album,
        duration: duration,
        displayTitle: _currentSong!.title,
        displaySubtitle: _currentSong!.artist,
      ));
    }
  }

  void _updatePlaybackState({AudioProcessingState? customProcessingState}) {
    final stateMapping = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    };

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: customProcessingState ?? (stateMapping[_player.processingState] ?? AudioProcessingState.idle),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  @override
  Future<void> play() async {
    debugPrint('MusicHandler: Play command received');
    await _player.play();
  }

  @override
  Future<void> pause() async {
    debugPrint('MusicHandler: Pause command received');
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    debugPrint('MusicHandler: Stopping player');
    await _player.stop();
    _currentSong = null;
    mediaItem.add(null);
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    debugPrint('MusicHandler: Skip to Next');
    onSkipToNextCall?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    debugPrint('MusicHandler: Skip to Previous');
    onSkipToPreviousCall?.call();
  }

  @override
  Future<void> onTaskRemoved() async {
    debugPrint('MusicHandler: onTaskRemoved (app swiped)');
    // If playing, keep service alive. 
    // Android 14+ needs this explicitly if we want to stay persistent.
    if (_player.playing) {
      _updatePlaybackState();
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    debugPrint('MusicHandler: Notification deleted');
    await stop();
  }

  Future<void> playSong(Song song) async {
    debugPrint('MusicHandler: Starting playback for ${song.title}');
    _currentSong = song;

    // 1. Update MediaItem immediately to satisfy Android MediaSession
    mediaItem.add(MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      displayTitle: song.title,
      displaySubtitle: song.artist,
    ));

    // 2. Force true playing and loading state to trigger foreground service immediately
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: AudioProcessingState.loading,
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
    ));

    try {
      final source = AudioSource.uri(Uri.file(song.filePath));
      await _player.setAudioSource(source);
      await _player.play();
      
      // 3. Final state update
      _updatePlaybackState();
      debugPrint('MusicHandler: Playback started successfully');
    } catch (e) {
      debugPrint('MusicHandler: Error loading audio: $e');
      _updatePlaybackState(customProcessingState: AudioProcessingState.error);
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Streams and Getters for PlaybackNotifier
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _volumeController.stream;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get volume => _player.volume;

  Future<void> setVolume(double vol) => _player.setVolume(vol);
  void setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  void dispose() {
    _player.dispose();
    _volumeController.close();
  }
}
