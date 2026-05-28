import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive.dart';
import '../providers/song_providers.dart';
import '../models/song.dart';
import '../widgets/song_artwork.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive(context);
    final playback = ref.watch(playbackProvider);
    final songs = ref.watch(songsProvider);
    
    final song = playback.currentSong;
    if (song == null) {
      return const Scaffold(
        body: Center(child: Text('No song selected')),
      );
    }

    final pos = playback.position;
    final dur = playback.duration;
    final posStr = _fmt(pos);
    final durStr = _fmt(dur);
    final progress = dur.inMilliseconds > 0
        ? pos.inMilliseconds / dur.inMilliseconds
        : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          _buildDynamicBackground(song),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, res, playback, ref),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = constraints.maxWidth > constraints.maxHeight;
                      if (isLandscape && res.isTablet) {
                        return _buildLandscape(context, res, playback, ref, song, posStr, durStr, progress);
                      }
                      return _buildPortrait(context, res, playback, ref, song, posStr, durStr, progress);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildDynamicBackground(Song song) {
    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned.fill(
          child: SongArtwork(
            song: song,
            size: double.infinity,
            borderRadius: 0,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait(BuildContext context, Responsive res, PlaybackState playback, WidgetRef ref,
      Song song, String posStr, String durStr, double progress) {
    final artSize = res.wp(75).clamp(200.0, 350.0);
    final isFav = ref.watch(favoritesProvider).any((s) => s.id == song.id);

    return Column(
      children: [
        const Spacer(),
        _buildAlbumArt(artSize, res, song),
        const Spacer(),
        _buildSongInfo(context, res, song, ref),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: res.wp(8)),
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFav ? Theme.of(context).colorScheme.primary : Colors.white38,
              ),
              iconSize: res.sp(28),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(favoritesProvider.notifier).toggle(song);
              },
            ),
          ),
        ),
        SizedBox(height: res.hp(1)),
        _buildProgress(context, posStr, durStr, progress, playback, ref, res),
        SizedBox(height: res.hp(4)),
        _buildControls(context, playback, ref, res),
        const Spacer(),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, Responsive res, PlaybackState playback, WidgetRef ref,
      Song song, String posStr, String durStr, double progress) {
    final artSize = res.hp(60).clamp(150.0, 300.0);
    final isFav = ref.watch(favoritesProvider).any((s) => s.id == song.id);

    return Row(
      children: [
        SizedBox(width: res.wp(10)),
        _buildAlbumArt(artSize, res, song),
        SizedBox(width: res.wp(8)),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSongInfo(context, res, song, ref),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: res.wp(8)),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: isFav ? Theme.of(context).colorScheme.primary : Colors.white38,
                    ),
                    iconSize: res.sp(28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggle(song);
                    },
                  ),
                ),
              ),
              SizedBox(height: res.hp(1)),
              _buildProgress(context, posStr, durStr, progress, playback, ref, res),
              SizedBox(height: res.hp(2)),
              _buildControls(context, playback, ref, res),
            ],
          ),
        ),
        SizedBox(width: res.wp(10)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Responsive res, PlaybackState playback, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(2), vertical: res.hp(1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
            iconSize: res.sp(32),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'NOW PLAYING',
            style: TextStyle(
              color: Colors.white60,
              fontSize: res.sp(10),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showSleepTimerDialog(context, playback, ref, res),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: res.wp(2.5), vertical: res.hp(0.6)),
                  decoration: BoxDecoration(
                    color: playback.isSleepTimerActive 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(res.wp(4)),
                    border: Border.all(
                      color: playback.isSleepTimerActive 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        playback.isSleepTimerActive ? Icons.timer_rounded : Icons.timer_outlined,
                        color: playback.isSleepTimerActive 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.white60,
                        size: res.sp(14),
                      ),
                      if (playback.isSleepTimerActive) ...[
                        SizedBox(width: res.wp(1)),
                        Text(
                          _formatDurationShort(playback.sleepTimerDuration!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: res.sp(11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDurationShort(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showSleepTimerDialog(BuildContext context, PlaybackState playback, WidgetRef ref, Responsive res) {
    double customMinutes = 30;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              left: res.wp(6),
              right: res.wp(6),
              top: res.wp(6),
              bottom: res.hp(4) + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: res.wp(12),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: res.hp(3)),
                Text(
                  'Sleep Timer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (playback.isSleepTimerActive) ...[
                  SizedBox(height: res.hp(2)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: res.wp(4), vertical: res.hp(1.5)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Remaining: ${_formatDuration(playback.sleepTimerDuration!)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: res.sp(16),
                      ),
                    ),
                  ),
                  SizedBox(height: res.hp(4)),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(playbackProvider.notifier).cancelSleepTimer();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.error,
                      minimumSize: Size(double.infinity, res.hp(7)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Stop Timer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  SizedBox(height: res.hp(4)),
                  Text(
                    '${customMinutes.toInt()} minutes',
                    style: TextStyle(
                      fontSize: res.sp(32),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: res.hp(2)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      thumbColor: Theme.of(context).colorScheme.primary,
                      overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: customMinutes,
                      min: 1,
                      max: 120,
                      divisions: 119,
                      onChanged: (value) {
                        setState(() => customMinutes = value);
                        if (value.toInt() % 5 == 0) {
                          HapticFeedback.selectionClick();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: res.hp(3)),
                  Wrap(
                    spacing: res.wp(3),
                    runSpacing: res.hp(1.5),
                    alignment: WrapAlignment.center,
                    children: [15, 30, 45, 60].map((mins) => ChoiceChip(
                      label: Text('$mins mins'),
                      selected: false,
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        ref.read(playbackProvider.notifier).setSleepTimer(Duration(minutes: mins));
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )).toList(),
                  ),
                  SizedBox(height: res.hp(4)),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(playbackProvider.notifier).setSleepTimer(
                        Duration(minutes: customMinutes.toInt()),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(double.infinity, res.hp(7)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text('Set Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  Widget _buildAlbumArt(double size, Responsive res, Song song) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: SongArtwork(
        song: song,
        size: size,
        borderRadius: res.wp(8),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, Responsive res, Song song, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: res.sp(26),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: res.hp(0.5)),
          Text(
            song.artist,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: res.sp(18),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, String pos, String dur, double progress,
      PlaybackState playback, WidgetRef ref, Responsive res) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.wp(8)),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final totalMs = playback.duration.inMilliseconds;
                ref.read(playbackProvider.notifier).seek(Duration(milliseconds: (totalMs * v).toInt()));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: res.wp(2)),
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

  Widget _buildControls(BuildContext context, PlaybackState playback, WidgetRef ref, Responsive res) {
    final btnSize = res.wp(18).clamp(60.0, 80.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  playback.isShuffled
                      ? Icons.shuffle_on_rounded
                      : Icons.shuffle_rounded,
                  key: ValueKey(playback.isShuffled),
                  color: playback.isShuffled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white38,
                  size: res.sp(26),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(playbackProvider.notifier).toggleShuffle();
              },
            ),
            Positioned(
              bottom: 4,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: playback.isShuffled ? 1.0 : 0.0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
          iconSize: res.sp(40),
          onPressed: () => ref.read(playbackProvider.notifier).previousSong(),
        ),
        Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.black,
            ),
            iconSize: res.sp(40),
            onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
          iconSize: res.sp(40),
          onPressed: () => ref.read(playbackProvider.notifier).nextSong(),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  playback.repeatMode == RepeatMode.one
                      ? Icons.repeat_one_on_rounded
                      : playback.repeatMode == RepeatMode.all
                          ? Icons.repeat_on_rounded
                          : Icons.repeat_rounded,
                  key: ValueKey(playback.repeatMode),
                  color: playback.repeatMode != RepeatMode.none
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white38,
                  size: res.sp(26),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(playbackProvider.notifier).cycleRepeatMode();
              },
            ),
            Positioned(
              bottom: 4,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: playback.repeatMode != RepeatMode.none ? 1.0 : 0.0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
