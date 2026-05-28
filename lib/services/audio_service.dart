import 'dart:async';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'music_handler.dart';

enum AudioState { stopped, playing, paused, loading, error }

class AudioPlayerService {
  final AudioPlayer _player;
  final MusicHandler? _handler;
  AudioState _state = AudioState.stopped;
  Song? _currentSong;

  AudioPlayerService(this._player, this._handler);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _player.volumeStream;

  AudioState get state => _state;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  double get volume => _player.volume;

  Future<void> play(Song song) async {
    try {
      _state = AudioState.loading;
      _currentSong = song;

      _handler?.setMediaItem(audio_service.MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        artUri: null,
        extras: {'filePath': song.filePath},
      ));

      await _player.setAudioSource(
        AudioSource.uri(Uri.file(song.filePath)),
      );
      await _player.play();
      _state = AudioState.playing;
    } catch (e) {
      _state = AudioState.error;
      debugPrint('AudioPlayerService play error: $e');
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
      _state = AudioState.paused;
    } else {
      await _player.play();
      _state = AudioState.playing;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _state = AudioState.paused;
  }

  Future<void> resume() async {
    await _player.play();
    _state = AudioState.playing;
  }

  Future<void> stop() async {
    await _player.stop();
    _state = AudioState.stopped;
    _currentSong = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void setLoopMode(LoopMode mode) {
    _player.setLoopMode(mode);
  }

  void dispose() {
    _player.dispose();
  }
}
