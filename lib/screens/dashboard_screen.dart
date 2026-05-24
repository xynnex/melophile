import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import '../widgets/song_card.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _quotes = [
    'Music is the language of the soul',
    'Let the rhythm move you',
    'Every song has a story',
    'Feel the beat, live the moment',
    'Your vibe attracts your tribe',
    'Lost in the music, found in the sound',
    'Life is better with headphones on',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final quote = _quotes[DateTime.now().day % _quotes.length];
    final hasData = provider.totalPlays > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _buildHeader(context, quote),
          const SizedBox(height: 24),
          _buildWeeklyChart(context, provider),
          const SizedBox(height: 24),
          _buildStatsRow(context, provider),
          if (hasData) ...[
            const SizedBox(height: 24),
            _buildNowPlayingCard(context, provider),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.recentHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'No songs played yet. Start listening!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...provider.recentHistory.map(
              (song) => SongCard(song: song, showFavorite: false),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String quote) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Boss',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF06B6D4),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white54,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, SongProvider provider) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayIndex = DateTime.now().weekday - 1;
    final data = provider.weeklyPlays;
    final maxData = data.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Listening',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF06B6D4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.totalPlays} total plays',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final height = maxData > 0
                    ? (data[i] / maxData) * 100
                    : 0.0;
                final isToday = i == dayIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${data[i]}',
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF06B6D4)
                                : Colors.white38,
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: height.clamp(16, 100),
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? const LinearGradient(
                                    colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF06B6D4)
                                : Colors.white38,
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, SongProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.access_time_rounded,
            label: 'Listening',
            value: provider.listeningTimeFormatted,
            color: const Color(0xFF06B6D4),
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            value: '${provider.favorites.length} songs',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.music_note_rounded,
            label: 'Total',
            value: '${provider.totalPlays}',
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, SongProvider provider) {
    final currentSong = provider.currentSong;
    if (currentSong == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF06B6D4).withValues(alpha: 0.15),
            const Color(0xFFF59E0B).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
              ),
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentSong.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentSong.artist,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
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
              size: 40,
            ),
            onPressed: () => provider.togglePlayPause(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
