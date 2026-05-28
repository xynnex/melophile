import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import '../models/song.dart';
import '../core/theme.dart';

class SongArtwork extends StatefulWidget {
  final Song song;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;

  const SongArtwork({
    super.key,
    required this.song,
    required this.size,
    this.borderRadius = 8,
    this.placeholderIcon = Icons.music_note_rounded,
  });

  @override
  State<SongArtwork> createState() => _SongArtworkState();
}

class _SongArtworkState extends State<SongArtwork> {
  // Simple static memory cache to prevent repeated disk reads
  static final Map<String, Uint8List> _artCache = {};
  Future<Uint8List?>? _artFuture;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  @override
  void didUpdateWidget(SongArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.filePath != widget.song.filePath) {
      _initFuture();
    }
  }

  void _initFuture() {
    if (_artCache.containsKey(widget.song.filePath)) {
      _artFuture = Future.value(_artCache[widget.song.filePath]);
    } else {
      _artFuture = _loadArtwork();
    }
  }

  Future<Uint8List?> _loadArtwork() async {
    try {
      final tag = await AudioTags.read(widget.song.filePath);
      if (tag != null && tag.pictures.isNotEmpty) {
        final bytes = tag.pictures.first.bytes;
        _artCache[widget.song.filePath] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('Error loading artwork: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _artFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return _buildImage(snapshot.data!);
        }
        // While loading or if no data, show placeholder
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildImage(Uint8List bytes) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        image: DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          colors: [
            AppTheme.gradientColors[widget.song.id.abs() % AppTheme.gradientColors.length],
            AppTheme.gradientColors[(widget.song.id.abs() + 1) % AppTheme.gradientColors.length],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: widget.placeholderIcon != Icons.music_note_rounded
            ? Icon(
                widget.placeholderIcon,
                color: Colors.white,
                size: widget.size.isFinite ? widget.size * 0.5 : 48,
              )
            : SvgPicture.asset(
                'assets/app_logo.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: widget.size.isFinite ? widget.size * 0.6 : 60,
              ),
      ),
    );
  }
}
