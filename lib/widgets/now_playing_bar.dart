import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive.dart';
import '../providers/song_providers.dart';
import '../screens/player_screen.dart';
import 'song_artwork.dart';

class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive(context);
    final playback = ref.watch(playbackProvider);

    if (playback.currentSong == null) {
      return const SizedBox.shrink();
    }

    final song = playback.currentSong!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: res.wp(5),
          vertical: res.hp(0.5),
        ),
        padding: EdgeInsets.fromLTRB(
          res.wp(2.5),
          res.hp(1.2),
          res.wp(1.5),
          res.hp(1.2),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(res.wp(4)),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SongArtwork(
              song: song,
              size: res.wp(10),
              borderRadius: res.wp(3),
            ),
            SizedBox(width: res.wp(3)),            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: res.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: res.hp(0.3)),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: res.sp(12),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                playback.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: res.sp(38),
              ),
              onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
            ),
          ],
        ),
      ),
    );
  }
}
