import 'dart:io';

class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String imageUrl;
  final String audioUrl;
  final String filePath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.duration = '0:00',
    this.imageUrl = '',
    this.audioUrl = '',
    this.filePath = '',
  });

  factory Song.fromFile(File file, int id) {
    final uri = Uri.file(file.path);
    final fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'Unknown';
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final segments = uri.pathSegments;
    final artist = segments.length > 1
        ? segments[segments.length - 2]
        : 'Unknown Artist';

    final length = _formatDuration(file.lengthSync());
    return Song(
      id: id,
      title: title,
      artist: artist,
      duration: length,
      filePath: file.path,
    );
  }

  static String _formatDuration(int bytes) {
    return '0:00';
  }
}
