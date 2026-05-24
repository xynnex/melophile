import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../models/song.dart';
import '../providers/song_provider.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showFavorite;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);

    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        final isCurrent = provider.currentSong?.id == song.id;
        final isFav = provider.isFavorite(song);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: res.wp(5),
            vertical: res.hp(0.5),
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(res.wp(3)),
            border: isCurrent
                ? Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(res.wp(3)),
              onTap: onTap ?? () => provider.playSong(song),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: res.wp(2.5),
                  vertical: res.hp(1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: res.wp(10),
                      height: res.wp(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(res.wp(2.5)),
                        gradient: LinearGradient(
                          colors: [
                            [const Color(0xFF06B6D4), const Color(0xFFF59E0B), const Color(0xFF6366F1), const Color(0xFF34D399), const Color(0xFFFBBF24)][song.id % 5],
                            [const Color(0xFFF59E0B), const Color(0xFF06B6D4), const Color(0xFF22D3EE), const Color(0xFFA3E635), const Color(0xFFFB923C)][song.id % 5],
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isCurrent ? Icons.equalizer_rounded : Icons.music_note_rounded,
                          color: Colors.white,
                          size: res.sp(22),
                        ),
                      ),
                    ),
                    SizedBox(width: res.wp(3)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              color: isCurrent
                                  ? const Color(0xFF06B6D4)
                                  : Colors.white,
                              fontSize: res.sp(15),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: res.hp(0.3)),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      song.duration,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    if (showFavorite)
                      IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFF59E0B)
                              : Colors.white38,
                          size: res.sp(20),
                        ),
                        onPressed: () => provider.toggleFavorite(song),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: res.wp(8),
                          minHeight: res.wp(8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
