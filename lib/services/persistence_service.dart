import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';

class PersistenceService {
  Box get _songsBox => Hive.box('songs');
  Box get _favoritesBox => Hive.box('favorites');
  Box get _historyBox => Hive.box('history');

  Future<void> saveSongs(List<Song> songs) async {
    try {
      if (!Hive.isBoxOpen('songs')) {
        debugPrint('PersistenceService.saveSongs: Box "songs" is not open.');
        return;
      }
      
      final List<Map<String, dynamic>> songsList = songs
          .where((s) => !s.isCorrupted && s.filePath.isNotEmpty)
          .map((s) => s.toMap())
          .toList();

      debugPrint('PersistenceService: Saving ${songsList.length} songs to Hive as a list...');
      
      // Use a single key for the entire list to avoid key range issues
      // We also use a secondary backup key for redundancy
      await _songsBox.put('library', songsList);
      await _songsBox.put('library_backup', songsList);
      
      await _songsBox.flush();
      debugPrint('PersistenceService: Library saved successfully');
    } catch (e) {
      debugPrint('PersistenceService.saveSongs error: $e');
    }
  }

  List<Song> getSongs() {
    try {
      if (!Hive.isBoxOpen('songs')) {
        debugPrint('PersistenceService.getSongs: Box "songs" is not open');
        return [];
      }
      
      // Try primary key first
      dynamic data = _songsBox.get('library');
      
      // Fallback to backup if primary is empty
      if (data == null || (data is List && data.isEmpty)) {
        data = _songsBox.get('library_backup');
      }

      if (data is List) {
        final List<Song> songs = data
            .map((item) => Song.fromMap(Map<dynamic, dynamic>.from(item as Map)))
            .where((s) => s.id != -1)
            .toList();
        debugPrint('PersistenceService: Loaded ${songs.length} songs from Hive list');
        return songs;
      }
      
      // Emergency fallback for very old formats (individual entries)
      final List<Song> oldSongs = [];
      for (var value in _songsBox.values) {
        if (value is Map && value.containsKey('filePath')) {
          final song = Song.fromMap(Map<dynamic, dynamic>.from(value));
          if (song.id != -1) oldSongs.add(song);
        }
      }
      if (oldSongs.isNotEmpty) {
        debugPrint('PersistenceService: Recovered ${oldSongs.length} songs from old format');
      }
      return oldSongs;
    } catch (e) {
      debugPrint('PersistenceService.getSongs error: $e');
      return [];
    }
  }

  Future<void> saveFavorite(Song song) async {
    try {
      if (song.id == -1) return;
      await _favoritesBox.put(song.filePath, song.toMap());
      await _favoritesBox.flush();
    } catch (e) {
      debugPrint('PersistenceService.saveFavorite error: $e');
    }
  }

  Future<void> removeFavorite(int songId) async {
    try {
      // Find key by matching ID in the map values
      final key = _favoritesBox.keys.firstWhere(
        (k) {
          final val = _favoritesBox.get(k);
          return val is Map && val['id'] == songId;
        },
        orElse: () => null,
      );
      if (key != null) {
        await _favoritesBox.delete(key);
        await _favoritesBox.flush();
      }
    } catch (e) {
      debugPrint('PersistenceService.removeFavorite error: $e');
    }
  }

  List<Song> getFavorites() {
    try {
      if (!Hive.isBoxOpen('favorites')) return [];
      
      final List<Song> favs = [];
      for (var value in _favoritesBox.values) {
        if (value is Map) {
          final song = Song.fromMap(Map<dynamic, dynamic>.from(value));
          if (song.id != -1) {
            favs.add(song);
          }
        }
      }
      return favs;
    } catch (e) {
      debugPrint('PersistenceService.getFavorites error: $e');
      return [];
    }
  }

  Future<void> addToHistory(Song song) async {
    try {
      if (song.id == -1) return;
      await _historyBox.add(song.toMap());
      if (_historyBox.length > 50) {
        await _historyBox.deleteAt(0);
      }
      await _historyBox.flush();
    } catch (e) {
      debugPrint('PersistenceService.addToHistory error: $e');
    }
  }

  List<Song> getHistory() {
    try {
      if (!Hive.isBoxOpen('history')) return [];
      
      final List<Song> history = [];
      for (var value in _historyBox.values) {
        if (value is Map) {
          final song = Song.fromMap(Map<dynamic, dynamic>.from(value));
          if (song.id != -1) {
            history.add(song);
          }
        }
      }
      return history.reversed.toList();
    } catch (e) {
      debugPrint('PersistenceService.getHistory error: $e');
      return [];
    }
  }

  Future<void> clearLibrary() async {
    try {
      await _songsBox.clear();
      await _favoritesBox.clear();
      await _historyBox.clear();
      await _songsBox.flush();
      await _favoritesBox.flush();
      await _historyBox.flush();
    } catch (e) {
      debugPrint('PersistenceService.clearLibrary error: $e');
    }
  }
}
