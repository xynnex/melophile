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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                res.wp(3),
                res.hp(0.8),
                res.wp(2),
                res.hp(0.8),
              ),
              child: Row(
                children: [
                  SongArtwork(
                    song: song,
                    size: res.wp(10),
                    borderRadius: res.wp(2.5),
                  ),
                  SizedBox(width: res.wp(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: res.sp(13.5),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: res.hp(0.2)),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: res.sp(11.5),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: res.wp(2)),
                  IconButton(
                    icon: Icon(
                      playback.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: res.sp(32),
                    ),
                    onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: res.wp(1.5)),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: res.wp(5),
              right: res.wp(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: playback.duration.inMilliseconds > 0
                      ? playback.position.inMilliseconds / playback.duration.inMilliseconds
                      : 0.0,
                  minHeight: 2.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
