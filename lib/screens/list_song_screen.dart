import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/responsive.dart';
import '../providers/song_providers.dart';
import '../widgets/song_card.dart';

class ListSongScreen extends ConsumerStatefulWidget {
  const ListSongScreen({super.key});

  @override
  ConsumerState<ListSongScreen> createState() => _ListSongScreenState();
}

class _ListSongScreenState extends ConsumerState<ListSongScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);
    final songs = ref.watch(songsProvider);
    
    final query = _searchController.text.toLowerCase();
    final filteredSongs = songs.where((song) =>
      song.title.toLowerCase().contains(query) ||
      song.artist.toLowerCase().contains(query)
    ).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: res.hp(18),
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: res.wp(5), bottom: 16),
              centerTitle: false,
              title: Text(
                'Music Library',
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
              padding: EdgeInsets.fromLTRB(res.wp(5), 0, res.wp(5), res.hp(2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${songs.length} songs available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: res.hp(2)),
                  _buildSearchBar(res),
                ],
              ),
            ),
          ),
          if (filteredSongs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(res),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SongCard(
                    song: filteredSongs[index],
                    playlist: filteredSongs,
                  );
                },
                childCount: filteredSongs.length,
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: res.hp(22)), // Space for NowPlayingBar
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Responsive res) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(res.wp(3)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search songs, artists...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: res.sp(14),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: res.sp(22),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: res.sp(20),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: res.wp(4),
            vertical: res.hp(1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Responsive res) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: res.wp(20),
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: res.hp(2)),
          Text(
            'No music found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: res.hp(1)),
          Text(
            'Try a different search or scan your device',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
