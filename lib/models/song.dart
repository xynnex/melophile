import 'dart:io';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/foundation.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final Uint8List? artwork;
  final String filePath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album = 'Unknown Album',
    this.duration = '0:00',
    this.artwork,
    this.filePath = '',
  });

  factory Song.fromFile(File file, int id) {
    final fileName = file.path.split('/').last;
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    
    return Song(
      id: id,
      title: title,
      artist: 'Unknown Artist',
      filePath: file.path,
    );
  }

  static Future<Song> fromFileWithMetadata(File file, int id) async {
    try {
      final tag = await AudioTags.read(file.path);
      if (tag == null) return Song.fromFile(file, id);

      final title = tag.title?.isNotEmpty == true 
          ? tag.title! 
          : file.path.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '');
      
      final artist = tag.trackArtist?.isNotEmpty == true ? tag.trackArtist! : 'Unknown Artist';
      final album = tag.album?.isNotEmpty == true ? tag.album! : 'Unknown Album';
      
      // Artwork is NOT loaded here to save memory. 
      // SongArtwork widget loads it lazily from filePath.

      return Song(
        id: id,
        title: title,
        artist: artist,
        album: album,
        filePath: file.path,
      );
    } catch (e) {
      debugPrint('Error reading tags for ${file.path}: $e');
      return Song.fromFile(file, id);
    }
  }

  static String formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'filePath': filePath,
    };
  }

  factory Song.fromMap(Map<dynamic, dynamic> map) {
    try {
      return Song(
        id: (map['id'] ?? 0) as int,
        title: (map['title'] ?? 'Unknown Title') as String,
        artist: (map['artist'] ?? 'Unknown Artist') as String,
        album: (map['album'] ?? 'Unknown Album') as String,
        duration: (map['duration'] ?? '0:00') as String,
        filePath: (map['filePath'] ?? '') as String,
      );
    } catch (e) {
      debugPrint('Song.fromMap error: $e. Map content: $map');
      return Song(id: -1, title: 'Corrupted Data', artist: '', filePath: '');
    }
  }

  bool get isCorrupted => id == -1;
}
