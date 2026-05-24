import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

enum PlaybackState { stopped, playing, paused }

class SongProvider extends ChangeNotifier {
  final List<Song> _songs = [];
  int _nextId = 1;
  Song? _currentSong;
  final AudioPlayer _player = AudioPlayer();
  PlaybackState _playbackState = PlaybackState.stopped;
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.none;
  int _currentIndex = -1;
  final List<Song> _favorites = [];
  final List<Song> _recentHistory = [];
  int _totalPlays = 0;
  int _listeningSeconds = 0;
  final List<int> _weeklyPlays = [0, 0, 0, 0, 0, 0, 0];
  bool _isScanning = false;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;

  AudioPlayer get player => _player;

  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  PlaybackState get playbackState => _playbackState;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? const Duration(seconds: 0);
  double get volume => _player.volume;
  bool get isShuffled => _isShuffled;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get favorites => _favorites;
  bool get isPlaying => _player.playing;
  bool get isScanning => _isScanning;

  List<Song> get recentHistory =>
    _recentHistory.length > 5
        ? _recentHistory.sublist(0, 5)
        : List.from(_recentHistory);

  int get totalPlays => _totalPlays;
  int get listeningSeconds => _listeningSeconds;
  List<int> get weeklyPlays => List.from(_weeklyPlays);

  String get listeningTimeFormatted {
    final hrs = _listeningSeconds ~/ 3600;
    final mins = (_listeningSeconds % 3600) ~/ 60;
    return hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
  }

  SongProvider() {
    _setupPlayerListeners();
    _setupAudioSession();
  }

  void _setupAudioSession() {
    _player.setVolume(0.8);
  }

  Timer? _listeningTimer;

  void _setupPlayerListeners() {
    _positionSub = _player.positionStream.listen((_) {
      notifyListeners();
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.playing) {
        _listeningTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
          if (_player.playing) {
            _listeningSeconds++;
            notifyListeners();
          }
        });
      } else {
        _listeningTimer?.cancel();
        _listeningTimer = null;
      }

      switch (state.processingState) {
        case ProcessingState.completed:
          _onTrackComplete();
          break;
        case ProcessingState.ready:
          if (_playbackState == PlaybackState.stopped) {
            _playbackState = PlaybackState.playing;
          }
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  void _onTrackComplete() {
    if (_repeatMode == RepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }
    nextSong();
  }

  bool isFavorite(Song song) => _favorites.any((s) => s.id == song.id);

  Future<void> playSong(Song song) async {
    final index = _songs.indexOf(song);
    if (index == -1) return;

    _currentIndex = index;
    _currentSong = song;
    _playbackState = PlaybackState.playing;
    _totalPlays++;
    _recentHistory.insert(0, song);
    final day = DateTime.now().weekday - 1;
    _weeklyPlays[day] = _weeklyPlays[day] + 1;

    if (song.filePath.isNotEmpty && File(song.filePath).existsSync()) {
      try {
        await _player.setFilePath(song.filePath);
        await _player.play();
      } catch (e) {
        debugPrint('playSong error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null && _songs.isNotEmpty) {
      await playSong(_songs[0]);
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> nextSong() async {
    if (_songs.isEmpty) return;
    if (_isShuffled) {
      _currentIndex = DateTime.now().microsecondsSinceEpoch % _songs.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _songs.length;
    }
    _currentSong = _songs[_currentIndex];
    _playbackState = PlaybackState.playing;
    _totalPlays++;
    _recentHistory.insert(0, _currentSong!);
    final day = DateTime.now().weekday - 1;
    _weeklyPlays[day] = _weeklyPlays[day] + 1;

    await _player.stop();
    if (_currentSong!.filePath.isNotEmpty && File(_currentSong!.filePath).existsSync()) {
      try {
        await _player.setFilePath(_currentSong!.filePath);
        await _player.play();
      } catch (e) {
        debugPrint('nextSong error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> previousSong() async {
    if (_songs.isEmpty) return;
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    _currentSong = _songs[_currentIndex];
    _playbackState = PlaybackState.playing;
    _totalPlays++;
    _recentHistory.insert(0, _currentSong!);
    final day = DateTime.now().weekday - 1;
    _weeklyPlays[day] = _weeklyPlays[day] + 1;

    await _player.stop();
    if (_currentSong!.filePath.isNotEmpty && File(_currentSong!.filePath).existsSync()) {
      try {
        await _player.setFilePath(_currentSong!.filePath);
        await _player.play();
      } catch (e) {
        debugPrint('previousSong error: $e');
      }
    }
    notifyListeners();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        _player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        _player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        _player.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    notifyListeners();
  }

  List<Song> search(String query) {
    if (query.isEmpty) return _songs;
    return _songs.where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
      song.artist.toLowerCase().contains(query.toLowerCase()),
    ).toList();
  }

  List<Song> getPlaylistSongs(String playlistName) {
    return _songs;
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    if (await Permission.storage.isGranted) return true;
    if (await Permission.audio.isGranted) return true;

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> pickAudioFiles() async {
    try {
      _isScanning = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg', 'wma'],
        allowMultiple: true,
        dialogTitle: 'Pilih file musik',
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            _addSongFromPath(file.path!);
          }
        }
      }
    } catch (e) {
      debugPrint('pickAudioFiles error: $e');
    }

    _isScanning = false;
    notifyListeners();
  }

  Future<void> scanDefaultDirectories() async {
    if (!Platform.isAndroid) return;

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      debugPrint('Storage permission denied');
      notifyListeners();
      return;
    }

    _isScanning = true;
    notifyListeners();

    try {
      for (final basePath in ['/storage/emulated/0/Music', '/storage/emulated/0/Download']) {
        final dir = Directory(basePath);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final ext = entity.path.toLowerCase();
              if (['.mp3', '.wav', '.aac', '.flac', '.m4a', '.ogg', '.wma'].any((e) => ext.endsWith(e))) {
                _addSongFromPath(entity.path);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('scanDefaultDirectories error: $e');
    }

    _isScanning = false;
    notifyListeners();
  }

  void _addSongFromPath(String path) {
    final alreadyExists = _songs.any((s) => s.filePath == path);
    if (alreadyExists) return;

    final song = Song.fromFile(File(path), _nextId++);
    _songs.add(song);
  }

  void clearSongs() {
    _player.stop();
    _songs.clear();
    _currentSong = null;
    _currentIndex = -1;
    _playbackState = PlaybackState.stopped;
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _listeningTimer?.cancel();
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _playbackState = PlaybackState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _listeningTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

enum RepeatMode { none, all, one }
