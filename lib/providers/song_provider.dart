import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/song.dart';

enum PlaybackState { stopped, playing, paused }

class SongProvider extends ChangeNotifier {
  final List<Song> _songs = [];
  int _nextId = 1;
  Song? _currentSong;
  PlaybackState _playbackState = PlaybackState.stopped;
  Duration _position = Duration.zero;
  double _volume = 0.8;
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.none;
  int _currentIndex = -1;
  final List<Song> _favorites = [];
  final List<Song> _recentHistory = [];
  int _totalPlays = 0;
  int _listeningSeconds = 0;
  final List<int> _weeklyPlays = [0, 0, 0, 0, 0, 0, 0];
  Timer? _timer;
  bool _isScanning = false;

  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  PlaybackState get playbackState => _playbackState;
  Duration get position => _position;
  Duration get duration => const Duration(seconds: 180);
  double get volume => _volume;
  bool get isShuffled => _isShuffled;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get favorites => _favorites;
  bool get isPlaying => _playbackState == PlaybackState.playing;
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

  bool isFavorite(Song song) => _favorites.any((s) => s.id == song.id);

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_playbackState == PlaybackState.playing) {
        _listeningSeconds++;
        _position += const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  void playSong(Song song) {
    final index = _songs.indexOf(song);
    if (index != -1) {
      _currentIndex = index;
      _currentSong = song;
      _playbackState = PlaybackState.playing;
      _position = Duration.zero;
      _totalPlays++;
      _recentHistory.insert(0, song);
      final day = DateTime.now().weekday - 1;
      _weeklyPlays[day] = _weeklyPlays[day] + 1;
      _startTimer();
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_currentSong == null && _songs.isNotEmpty) {
      playSong(_songs[0]);
      return;
    }
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
      _timer?.cancel();
    } else {
      _playbackState = PlaybackState.playing;
      _startTimer();
    }
    notifyListeners();
  }

  void nextSong() {
    if (_songs.isEmpty) return;
    if (_isShuffled) {
      _currentIndex = DateTime.now().microsecondsSinceEpoch % _songs.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _songs.length;
    }
    _currentSong = _songs[_currentIndex];
    _playbackState = PlaybackState.playing;
    _position = Duration.zero;
    _totalPlays++;
    _recentHistory.insert(0, _currentSong!);
    final day = DateTime.now().weekday - 1;
    _weeklyPlays[day] = _weeklyPlays[day] + 1;
    notifyListeners();
  }

  void previousSong() {
    if (_songs.isEmpty) return;
    if (_position > const Duration(seconds: 3)) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }
    _currentIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    _currentSong = _songs[_currentIndex];
    _playbackState = PlaybackState.playing;
    _position = Duration.zero;
    _totalPlays++;
    _recentHistory.insert(0, _currentSong!);
    final day = DateTime.now().weekday - 1;
    _weeklyPlays[day] = _weeklyPlays[day] + 1;
    notifyListeners();
  }

  void seek(Duration position) {
    _position = position;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
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
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
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
    _songs.clear();
    _currentSong = null;
    _currentIndex = -1;
    _playbackState = PlaybackState.stopped;
    _position = Duration.zero;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

enum RepeatMode { none, all, one }
