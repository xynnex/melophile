import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

class FileScannerService {
  Future<List<Song>> scanSelectedDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Pilih folder musik',
      );

      if (result != null) {
        final realPath = _resolveRealPath(result);
        if (realPath != null) {
          return await _scanDirectory(realPath);
        }
      }
    } catch (e) {
      debugPrint('FileScannerService scanSelectedDirectory error: $e');
    }
    return [];
  }

  Future<List<Song>> scanDefaultDirectories() async {
    final List<Song> allSongs = [];
    for (final basePath in ['/storage/emulated/0/Music', '/storage/emulated/0/Download']) {
      final songs = await _scanDirectory(basePath);
      allSongs.addAll(songs);
    }
    return allSongs;
  }

  String? _resolveRealPath(String path) {
    if (path.startsWith('/')) return path;
    if (path.contains(':')) {
      try {
        final parts = path.split(':');
        final relative = parts.last;
        return '/storage/emulated/0/$relative';
      } catch (_) {}
    }
    return null;
  }

  Future<List<Song>> _scanDirectory(String path) async {
    final List<Song> songs = [];
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return [];

      int nextId = DateTime.now().millisecondsSinceEpoch;

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = entity.path.toLowerCase();
          if (['.mp3', '.wav', '.aac', '.flac', '.m4a', '.ogg', '.wma'].any((e) => ext.endsWith(e))) {
            final song = await Song.fromFileWithMetadata(entity, nextId++);
            songs.add(song);
          }
        }
      }
    } catch (e) {
      debugPrint('FileScannerService _scanDirectory error: $e');
    }
    return songs;
  }
}
