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
        debugPrint('PersistenceService.saveSongs: Box "songs" is not open. Cannot save.');
        return;
      }
      
      final Map<int, Map<String, dynamic>> songsMap = {};
      final Set<String> processedPaths = {};

      for (var song in songs) {
        if (song.isCorrupted || song.filePath.isEmpty || processedPaths.contains(song.filePath)) continue;
        
        songsMap[song.id] = song.toMap();
        processedPaths.add(song.filePath);
      }

      debugPrint('PersistenceService: Saving ${songsMap.length} songs to Hive...');
      await _songsBox.clear();
      if (songsMap.isNotEmpty) {
        await _songsBox.putAll(songsMap);
        await _songsBox.flush(); // Force write to disk
      }
      debugPrint('PersistenceService: Successfully saved songs');
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
      
      final List<Song> songs = [];
      final values = _songsBox.values;
      debugPrint('PersistenceService: Found ${values.length} raw records in Hive');

      for (var value in values) {
        if (value != null && value is Map) {
          final song = Song.fromMap(Map<dynamic, dynamic>.from(value));
          if (song.id != -1) {
            songs.add(song);
          }
        }
      }
      debugPrint('PersistenceService: Successfully parsed ${songs.length} songs');
      return songs;
    } catch (e) {
      debugPrint('PersistenceService.getSongs error: $e');
      return [];
    }
  }

  Future<void> saveFavorite(Song song) async {
    try {
      if (song.id == -1) return;
      await _favoritesBox.put(song.id, song.toMap());
    } catch (e) {
      debugPrint('PersistenceService.saveFavorite error: $e');
    }
  }

  Future<void> removeFavorite(int songId) async {
    try {
      await _favoritesBox.delete(songId);
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
      
      // Prevent duplicates in history box if possible
      // (Hive add just appends, so we might want to check or use put)
      await _historyBox.add(song.toMap());
      
      // Limit history size
      if (_historyBox.length > 50) {
        await _historyBox.deleteAt(0);
      }
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
    } catch (e) {
      debugPrint('PersistenceService.clearLibrary error: $e');
    }
  }
}
