import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../providers/song_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  if (isLandscape && res.isTablet) {
                    return _buildLandscape(context, res, provider, song, posStr, durStr, progress);
                  }
                  return _buildPortrait(context, res, provider, song, posStr, durStr, progress);
                },
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

  Widget _buildPortrait(BuildContext context, Responsive res, SongProvider provider,
      dynamic song, String posStr, String durStr, double progress) {
    final artSize = res.wp(55).clamp(180.0, 320.0);

    return Column(
      children: [
        _buildAppBar(context, res, provider),
        const Spacer(flex: 1),
        _buildAlbumArt(artSize, res, provider),
        const Spacer(flex: 2),
        _buildSongInfo(context, res, song),
        SizedBox(height: res.hp(3)),
        _buildProgress(posStr, durStr, progress, provider, res),
        SizedBox(height: res.hp(3)),
        _buildControls(context, provider, res),
        SizedBox(height: res.hp(2)),
        _buildVolumeSlider(provider, res),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, Responsive res, SongProvider provider,
      dynamic song, String posStr, String durStr, double progress) {
    final artSize = res.hp(35).clamp(120.0, 240.0);

    return Row(
      children: [
        SizedBox(width: res.wp(5)),
        _buildAlbumArt(artSize, res, provider),
        SizedBox(width: res.wp(5)),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSongInfo(context, res, song),
              SizedBox(height: res.hp(2)),
              _buildProgress(posStr, durStr, progress, provider, res),
              SizedBox(height: res.hp(2)),
              _buildControls(context, provider, res),
              SizedBox(height: res.hp(2)),
              _buildVolumeSlider(provider, res),
            ],
          ),
        ),
        SizedBox(width: res.wp(5)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Responsive res, SongProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(2), vertical: res.hp(0.5)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
            iconSize: res.sp(28),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (provider.currentSong != null)
            IconButton(
              icon: Icon(
                provider.isFavorite(provider.currentSong!)
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: provider.isFavorite(provider.currentSong!)
                    ? const Color(0xFFF59E0B)
                    : Colors.white38,
              ),
              iconSize: res.sp(24),
              onPressed: () {
                if (provider.currentSong != null) {
                  provider.toggleFavorite(provider.currentSong!);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(double size, Responsive res, SongProvider provider) {
    final isPlaying = provider.isPlaying;

    return GestureDetector(
      onTap: () => provider.togglePlayPause(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              blurRadius: size * 0.15,
              offset: Offset(0, size * 0.04),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.equalizer_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: size * 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, Responsive res, dynamic song) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(8)),
      child: Column(
        children: [
          Text(
            song.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: res.sp(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: res.hp(1)),
          Text(
            song.artist,
            style: TextStyle(
              color: Colors.white54,
              fontSize: res.sp(16),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(String pos, String dur, double progress,
      SongProvider provider, Responsive res) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(8)),
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
            padding: EdgeInsets.symmetric(horizontal: res.wp(1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pos, style: TextStyle(color: Colors.white38, fontSize: res.sp(12))),
                Text(dur, style: TextStyle(color: Colors.white38, fontSize: res.sp(12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, SongProvider provider, Responsive res) {
    final btnSize = res.wp(12).clamp(40.0, 64.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            provider.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
            color: provider.isShuffled ? const Color(0xFF06B6D4) : Colors.white38,
            size: res.sp(24),
          ),
          onPressed: () => provider.toggleShuffle(),
        ),
        SizedBox(width: res.wp(3)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(btnSize * 0.25),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
            iconSize: res.sp(30),
            onPressed: () => provider.previousSong(),
          ),
        ),
        SizedBox(width: res.wp(3)),
        Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4),
            borderRadius: BorderRadius.circular(btnSize * 0.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                blurRadius: btnSize * 0.25,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
            ),
            iconSize: res.sp(34),
            onPressed: () => provider.togglePlayPause(),
          ),
        ),
        SizedBox(width: res.wp(3)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(btnSize * 0.25),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
            iconSize: res.sp(30),
            onPressed: () => provider.nextSong(),
          ),
        ),
        SizedBox(width: res.wp(3)),
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
            size: res.sp(24),
          ),
          onPressed: () => provider.cycleRepeatMode(),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(SongProvider provider, Responsive res) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(12)),
      child: Row(
        children: [
          Icon(Icons.volume_down_rounded, color: Colors.white38, size: res.sp(18)),
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
          Icon(Icons.volume_up_rounded, color: Colors.white38, size: res.sp(18)),
        ],
      ),
    );
  }
}
