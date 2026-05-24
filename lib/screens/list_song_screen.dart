import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
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
    final res = Responsive(context);
    final provider = context.watch<SongProvider>();
    final query = _searchController.text;
    final songs = provider.search(query);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: res.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: res.hp(4)),
            Text(
              'Music Library',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: res.sp(28),
              ),
            ),
            SizedBox(height: res.hp(1)),
            Text(
              '${provider.songs.length} songs available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: res.sp(14),
              ),
            ),
            SizedBox(height: res.hp(2.5)),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(res.wp(4)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: Colors.white, fontSize: res.sp(15)),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists...',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: res.sp(14),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white38,
                    size: res.sp(22),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.white38,
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
            ),
            SizedBox(height: res.hp(2.5)),
            if (songs.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: res.wp(4),
                  vertical: res.hp(5),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_music_outlined,
                      size: res.wp(15),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'No music found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white38,
                        fontSize: res.sp(18),
                      ),
                    ),
                    SizedBox(height: res.hp(1)),
                    Text(
                      'Go to Settings to scan your music folder',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white24,
                        fontSize: res.sp(14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...songs.map((song) => SongCard(song: song)),
            SizedBox(height: res.hp(4)),
          ],
        ),
      ),
    );
  }
}
