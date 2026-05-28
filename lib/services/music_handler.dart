import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
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

    // Listen to player state changes
    _player.playbackEventStream.listen(_onPlaybackEvent);
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen(_onPositionChanged);
    _player.durationStream.listen(_onDurationChanged);
    _player.volumeStream.listen((v) => _volumeController.add(v));
    
    // Listen to sequence state (current index)
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final index = sequenceState.currentIndex;
      if (index >= 0 && index < _playlist.length) {
        final source = _playlist.children[index] as UriAudioSource;
        final item = source.tag as MediaItem;
        mediaItem.add(item);
        _currentSong = _songFromMediaItem(item);
      }
    });

    // Initial state
    _updatePlaybackState();
    debugPrint('MusicHandler: Initialization complete');
  }

  Song? _songFromMediaItem(MediaItem item) {
    // Helper to find song in current provider state might be needed, 
    // or just rely on MediaItem for UI.
    return null; 
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    _updatePlaybackState();
  }

  void _onPlayerStateChanged(PlayerState state) {
    _updatePlaybackState();
  }

  void _onPositionChanged(Duration position) {
    if (position.inSeconds != playbackState.value.updatePosition.inSeconds) {
      _updatePlaybackState();
    }
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null && mediaItem.value != null) {
      mediaItem.add(mediaItem.value!.copyWith(duration: duration));
    }
  }

  void _updatePlaybackState({AudioProcessingState? customProcessingState, bool? forcePlaying}) {
    final stateMapping = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    };

    final isPlaying = forcePlaying ?? _player.playing;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
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
        MediaAction.fastForward,
        MediaAction.rewind,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: customProcessingState ?? (stateMapping[_player.processingState] ?? AudioProcessingState.idle),
      playing: isPlaying,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    _updatePlaybackState();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    _updatePlaybackState();
  }

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    final sources = songs.map((song) {
      final item = MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        displayTitle: song.title,
        displaySubtitle: song.artist,
        duration: _parseDuration(song.duration),
      );
      return AudioSource.uri(Uri.file(song.filePath), tag: item);
    }).toList();

    // Only update if the playlist has actually changed to avoid interruptions
    // For now, simple clear and add is okay, but we should be careful with the completed state
    await _playlist.clear();
    await _playlist.addAll(sources);
    
    if (_player.audioSource != _playlist) {
      await _player.setAudioSource(_playlist, initialIndex: initialIndex);
    } else {
      await _player.seek(Duration.zero, index: initialIndex);
    }
  }

  Future<void> playSong(Song song) async {
    // Fallback if not using setPlaylist yet
    await setPlaylist([song]);
    await _player.play();
  }

  Duration? _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        return Duration(minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
      } else if (parts.length == 3) {
        return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]), seconds: int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
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
