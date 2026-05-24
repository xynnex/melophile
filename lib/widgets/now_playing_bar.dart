import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../providers/song_provider.dart';
import '../screens/player_screen.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);

    return Consumer<SongProvider>(
      builder: (context, provider, _) {
        if (provider.currentSong == null) {
          return const SizedBox.shrink();
        }

        final song = provider.currentSong!;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlayerScreen(),
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
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(res.wp(4)),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
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
                Container(
                  width: res.wp(10),
                  height: res.wp(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(res.wp(3)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: res.sp(22),
                    ),
                  ),
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
                          color: Colors.white54,
                          fontSize: res.sp(12),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    provider.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: const Color(0xFF06B6D4),
                    size: res.sp(38),
                  ),
                  onPressed: () => provider.togglePlayPause(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
