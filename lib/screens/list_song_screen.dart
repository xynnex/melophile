import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import '../widgets/song_card.dart';

class ListSongScreen extends StatefulWidget {
  const ListSongScreen({super.key});

  @override
  State<ListSongScreen> createState() => _ListSongScreenState();
}

class _ListSongScreenState extends State<ListSongScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final query = _searchController.text;
    final songs = provider.search(query);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Music Library',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${provider.songs.length} songs available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white38,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (songs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No music found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Settings to scan your music folder',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...songs.map((song) => SongCard(song: song)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
