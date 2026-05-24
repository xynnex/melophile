import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        final isCurrent = provider.currentSong?.id == song.id;
        final isFav = provider.isFavorite(song);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: isCurrent
                ? Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap ?? () => provider.playSong(song),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
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
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${song.artist} • ${song.album}',
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
                          size: 20,
                        ),
                        onPressed: () => provider.toggleFavorite(song),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
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
