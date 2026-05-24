import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('No song selected')),
          );
        }

        final pos = provider.position;
        final dur = provider.duration;
        final posStr = _fmt(pos);
        final durStr = _fmt(dur);
        final progress = dur.inMilliseconds > 0
            ? pos.inMilliseconds / dur.inMilliseconds
            : 0.0;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF111122),
                  Color(0xFF0D0D0D),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  const Spacer(flex: 1),
                  _buildAlbumArt(context, provider),
                  const Spacer(flex: 2),
                  _buildSongInfo(context, song),
                  const SizedBox(height: 24),
                  _buildProgress(posStr, durStr, progress, provider),
                  const SizedBox(height: 24),
                  _buildControls(context, provider),
                  const SizedBox(height: 20),
                  _buildVolumeSlider(provider),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Consumer<SongProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.isFavorite(provider.currentSong!)
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: provider.isFavorite(provider.currentSong!)
                    ? const Color(0xFFF59E0B)
                    : Colors.white38,
              ),
              onPressed: () {
                if (provider.currentSong != null) {
                  provider.toggleFavorite(provider.currentSong!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, SongProvider provider) {
    final isPlaying = provider.isPlaying;

    return GestureDetector(
      onTap: () => provider.togglePlayPause(),
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.equalizer_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(String pos, String dur, double progress, SongProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFF06B6D4),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFF06B6D4),
              overlayColor: const Color(0xFF06B6D4).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final totalMs = provider.duration.inMilliseconds;
                provider.seek(Duration(milliseconds: (totalMs * v).toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pos, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                Text(dur, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, SongProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            provider.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
            color: provider.isShuffled ? const Color(0xFF06B6D4) : Colors.white38,
            size: 24,
          ),
          onPressed: () => provider.toggleShuffle(),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 30),
            onPressed: () => provider.previousSong(),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                blurRadius: 16,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
            onPressed: () => provider.togglePlayPause(),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
            onPressed: () => provider.nextSong(),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            provider.repeatMode == RepeatMode.one
                ? Icons.repeat_one_on_rounded
                : provider.repeatMode == RepeatMode.all
                    ? Icons.repeat_on_rounded
                    : Icons.repeat_rounded,
            color: provider.repeatMode != RepeatMode.none
                ? const Color(0xFF06B6D4)
                : Colors.white38,
            size: 24,
          ),
          onPressed: () => provider.cycleRepeatMode(),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(SongProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Icon(Icons.volume_down_rounded, color: Colors.white38, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.white38,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white54,
                overlayColor: Colors.white.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: provider.volume,
                onChanged: (v) => provider.setVolume(v),
              ),
            ),
          ),
          Icon(Icons.volume_up_rounded, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}
