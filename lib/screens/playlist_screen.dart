import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive.dart';
import '../providers/song_providers.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive(context);
    final songs = ref.watch(songsProvider);
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: res.hp(18),
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: res.wp(5)),
                child: IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: res.wp(5), bottom: 16),
              centerTitle: false,
              title: Text(
                'Your Playlists',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: res.sp(22),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: res.wp(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${songs.length} songs in library',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: res.hp(3)),
                  _buildPlaylistGrid(context, res, ref, songs.length, favorites.length, history.length),
                  SizedBox(height: res.hp(22)), // Space for NowPlayingBar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(BuildContext context, Responsive res, WidgetRef ref, int totalSongs, int totalFavs, int totalHistory) {
    final crossAxisCount = res.gridCrossAxisCount().toInt();

    final playlists = [
      _PlaylistData('Favorites', totalFavs, Icons.favorite_rounded, Theme.of(context).colorScheme.secondary),
      _PlaylistData('Recently Played', totalHistory, Icons.history_rounded, Theme.of(context).colorScheme.primary),
      _PlaylistData('All Songs', totalSongs, Icons.library_music_rounded, const Color(0xFF6366F1)),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
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
                    color: playlist.color.withValues(alpha: 0.1),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: res.sp(15),
                      ),
                ),
                SizedBox(height: res.hp(0.5)),
                Text(
                  '${playlist.songCount} songs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
