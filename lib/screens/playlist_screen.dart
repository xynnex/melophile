import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../providers/song_provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);
    final provider = context.watch<SongProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: res.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: res.hp(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Playlists',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: res.sp(28),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(res.wp(3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    iconSize: res.sp(22),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: res.hp(1)),
            Text(
              '${provider.songs.length} songs in library',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: res.sp(14),
              ),
            ),
            SizedBox(height: res.hp(3)),
            _buildPlaylistGrid(context, res, provider),
            SizedBox(height: res.hp(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistGrid(BuildContext context, Responsive res, SongProvider provider) {
    final crossAxisCount = res.gridCrossAxisCount().toInt();

    final playlists = [
      _PlaylistData('Favorites', provider.favorites.length, Icons.favorite_rounded, const Color(0xFFF59E0B)),
      _PlaylistData('Recently Played', provider.recentHistory.length, Icons.history_rounded, const Color(0xFF06B6D4)),
      _PlaylistData('All Songs', provider.songs.length, Icons.library_music_rounded, const Color(0xFF6366F1)),
      _PlaylistData('Chill Vibes', 0, Icons.waves_rounded, const Color(0xFF34D399)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: res.isDesktop ? 1.3 : 1.1,
        crossAxisSpacing: res.wp(3),
        mainAxisSpacing: res.wp(3),
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _PlaylistCard(res: res, playlist: playlist);
      },
    );
  }
}

class _PlaylistData {
  final String name;
  final int songCount;
  final IconData icon;
  final Color color;

  _PlaylistData(this.name, this.songCount, this.icon, this.color);
}

class _PlaylistCard extends StatelessWidget {
  final Responsive res;
  final _PlaylistData playlist;

  const _PlaylistCard({required this.res, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(4)),
        color: const Color(0xFF1E1E1E),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(res.wp(4)),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(res.wp(3.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: res.wp(10),
                  height: res.wp(10),
                  decoration: BoxDecoration(
                    color: playlist.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(res.wp(3)),
                  ),
                  child: Icon(
                    playlist.icon,
                    color: playlist.color,
                    size: res.sp(22),
                  ),
                ),
                const Spacer(),
                Text(
                  playlist.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: res.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: res.hp(0.5)),
                Text(
                  '${playlist.songCount} songs',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: res.sp(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
