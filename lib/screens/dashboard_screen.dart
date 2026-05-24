import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
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
    final res = Responsive(context);
    final provider = context.watch<SongProvider>();
    final quote = _quotes[DateTime.now().day % _quotes.length];
    final hasData = provider.totalPlays > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: res.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: res.hp(4)),
            _buildHeader(context, res, quote),
            SizedBox(height: res.hp(3)),
            _buildWeeklyChart(context, res, provider),
            SizedBox(height: res.hp(3)),
            _buildStatsRow(context, res, provider),
            if (hasData) ...[
              SizedBox(height: res.hp(3)),
              _buildNowPlayingCard(context, res, provider),
            ],
            SizedBox(height: res.hp(3)),
            Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: res.hp(1.5)),
            if (provider.recentHistory.isEmpty)
              Text(
                'No songs played yet. Start listening!',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...provider.recentHistory.map(
                (song) => SongCard(song: song, showFavorite: false),
              ),
            SizedBox(height: res.hp(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive res, String quote) {
    return Row(
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
              SizedBox(height: res.hp(0.3)),
              Text(
                'Boss',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: res.sp(28),
                ),
              ),
              SizedBox(height: res.hp(1)),
              Text(
                '"$quote"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF06B6D4),
                  fontSize: res.sp(13),
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
                width: res.wp(10),
                height: res.wp(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(res.wp(3)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: Colors.white54,
                  size: res.sp(22),
                ),
              ),
            ),
            SizedBox(width: res.wp(2)),
            Container(
              width: res.wp(11),
              height: res.wp(11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(res.wp(3.5)),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: res.sp(24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Responsive res, SongProvider provider) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayIndex = DateTime.now().weekday - 1;
    final data = provider.weeklyPlays;
    final maxData = data.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(4)),
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
                  fontSize: res.sp(16),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: res.wp(2),
                    height: res.wp(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF06B6D4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: res.wp(1.5)),
                  Text(
                    '${provider.totalPlays} total plays',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: res.sp(11),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: res.hp(2.5)),
          SizedBox(
            height: res.hp(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final height = maxData > 0
                    ? (data[i] / maxData) * 100
                    : 0.0;
                final isToday = i == dayIndex;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: res.wp(0.8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${data[i]}',
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF06B6D4)
                                : Colors.white38,
                            fontSize: res.sp(10),
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: res.hp(0.8)),
                        Container(
                          height: height.clamp(16, res.hp(12)),
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
                            borderRadius: BorderRadius.circular(res.wp(1.5)),
                          ),
                        ),
                        SizedBox(height: res.hp(1)),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF06B6D4)
                                : Colors.white38,
                            fontSize: res.sp(11),
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

  Widget _buildStatsRow(BuildContext context, Responsive res, SongProvider provider) {
    return Row(
      children: [
        _StatCard(
          res: res,
          icon: Icons.access_time_rounded,
          label: 'Listening',
          value: provider.listeningTimeFormatted,
          color: const Color(0xFF06B6D4),
        ),
        SizedBox(width: res.wp(2.5)),
        _StatCard(
          res: res,
          icon: Icons.favorite_rounded,
          label: 'Favorites',
          value: '${provider.favorites.length} songs',
          color: const Color(0xFFF59E0B),
        ),
        SizedBox(width: res.wp(2.5)),
        _StatCard(
          res: res,
          icon: Icons.music_note_rounded,
          label: 'Total',
          value: '${provider.totalPlays}',
          color: const Color(0xFF06B6D4),
        ),
      ],
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, Responsive res, SongProvider provider) {
    final currentSong = provider.currentSong;
    if (currentSong == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(res.wp(3.5)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(4)),
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
            width: res.wp(11),
            height: res.wp(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(res.wp(3)),
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFF59E0B)],
              ),
            ),
            child:
                Icon(Icons.music_note_rounded, color: Colors.white, size: res.sp(24)),
          ),
          SizedBox(width: res.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now Playing',
                  style: TextStyle(
                    color: const Color(0xFF06B6D4),
                    fontSize: res.sp(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: res.hp(0.5)),
                Text(
                  currentSong.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: res.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentSong.artist,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: res.sp(13),
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
              size: res.sp(40),
            ),
            onPressed: () => provider.togglePlayPause(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Responsive res;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.res,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(2),
          horizontal: res.wp(2.5),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(res.wp(4)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: res.sp(22)),
            SizedBox(height: res.hp(1)),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: res.sp(14),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: res.hp(0.3)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white38,
                fontSize: res.sp(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
