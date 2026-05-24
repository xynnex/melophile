import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Playlists',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${provider.songs.length} songs in library',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          _buildPlaylistGrid(context, provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(BuildContext context, SongProvider provider) {
    final playlists = [
      _PlaylistData('Favorites', provider.favorites.length, Icons.favorite_rounded, const Color(0xFFF59E0B)),
      _PlaylistData('Recently Played', provider.recentHistory.length, Icons.history_rounded, const Color(0xFF06B6D4)),
      _PlaylistData('All Songs', provider.songs.length, Icons.library_music_rounded, const Color(0xFF6366F1)),
      _PlaylistData('Chill Vibes', 0, Icons.waves_rounded, const Color(0xFF34D399)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return _PlaylistCard(playlist: playlist);
        },
      ),
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
  final _PlaylistData playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: playlist.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    playlist.icon,
                    color: playlist.color,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${playlist.songCount} songs',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
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
