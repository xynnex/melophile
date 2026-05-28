import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  Song? _currentSong;
  final _volumeController = StreamController<double>.broadcast();

  MusicHandler() {
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen(_onPositionChanged);
    _player.durationStream.listen(_onDurationChanged);
    _player.volumeStream.listen((v) => _volumeController.add(v));
  }

  void _onPlayerStateChanged(PlayerState state) {
    playbackState.add(playbackState.value.copyWith(
      playing: state.playing,
      processingState: state.processingState == ProcessingState.ready
          ? AudioProcessingState.ready
          : state.processingState == ProcessingState.loading
              ? AudioProcessingState.loading
              : AudioProcessingState.idle,
      updatePosition: _player.position,
    ));
  }

  void _onPositionChanged(Duration position) {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }

  void _onDurationChanged(Duration? duration) {
    // Duration is not needed in PlaybackState, only in MediaItem
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    await _player.setAudioSource(
      AudioSource.uri(Uri.file(song.filePath)),
    );
    mediaItem.add(MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
    ));
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => Future.value();

  @override
  Future<void> skipToPrevious() => Future.value();

  // Exposed for PlaybackNotifier
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
