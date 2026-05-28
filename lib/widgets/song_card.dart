import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive.dart';
import '../models/song.dart';
import '../providers/song_providers.dart';
import 'song_artwork.dart';

class SongCard extends ConsumerWidget {
  final Song song;
  final List<Song>? playlist;
  final VoidCallback? onTap;
  final bool showFavorite;
  final int? index;

  const SongCard({
    super.key,
    required this.song,
    this.playlist,
    this.onTap,
    this.showFavorite = true,
    this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive(context);
    final playback = ref.watch(playbackProvider);
    final favorites = ref.watch(favoritesProvider);
    
    final isCurrent = playback.currentSong?.id == song.id;
    final isFav = favorites.any((s) => s.id == song.id);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: res.wp(5),
        vertical: res.hp(0.5),
      ),
      decoration: BoxDecoration(
        color: isCurrent
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(res.wp(3)),
        border: isCurrent
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(res.wp(3)),
          onTap: onTap ?? () => ref.read(playbackProvider.notifier).play(song, playlist: playlist),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: res.wp(3),
              vertical: res.hp(1.2),
            ),
            child: Row(
              children: [
                if (index != null) ...[
                  SizedBox(
                    width: res.wp(6),
                    child: Text(
                      '${index! + 1}',
                      style: TextStyle(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white38,
                        fontSize: res.sp(14),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: res.wp(2)),
                ],
                SongArtwork(
                  song: song,
                  size: res.wp(12),
                  borderRadius: res.wp(2.5),
                  placeholderIcon: isCurrent ? Icons.equalizer_rounded : Icons.music_note_rounded,
                ),
                SizedBox(width: res.wp(3.5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: res.sp(15),
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: res.hp(0.4)),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
                              : Colors.white54,
                          fontSize: res.sp(13),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: res.wp(2)),
                Text(
                  song.duration,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: res.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showFavorite) ...[
                  SizedBox(width: res.wp(1)),
                  IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white38,
                      size: res.sp(20),
                    ),
                    onPressed: () => ref.read(favoritesProvider.notifier).toggle(song),
                    padding: EdgeInsets.all(res.wp(1)),
                    constraints: const BoxConstraints(),
                    splashRadius: res.wp(6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
