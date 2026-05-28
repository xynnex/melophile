import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MusicHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  MusicHandler(this._player) {
    _player.playerStateStream.listen((state) {
      final current = playbackState.valueOrNull ?? PlaybackState();
      playbackState.add(current.copyWith(
        playing: state.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState] ?? AudioProcessingState.idle,
      ));
    });
    _player.positionStream.listen((pos) {
      final current = playbackState.valueOrNull ?? PlaybackState();
      playbackState.add(current.copyWith(updatePosition: pos));
    });
    _player.durationStream.listen((dur) {
      final current = playbackState.valueOrNull ?? PlaybackState();
      playbackState.add(current.copyWith(bufferedPosition: dur ?? Duration.zero));
    });
  }

  void setMediaItem(MediaItem item) {
    mediaItem.add(item);
    queue.add([item]);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}
}
