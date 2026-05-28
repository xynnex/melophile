import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../providers/song_providers.dart';
import '../widgets/song_card.dart';
import 'player_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _quotes = [
    'Music is the language of the soul',
    'Let the rhythm move you',
    'Every song has a story',
    'Feel the beat, live the moment',
    'Your vibe attracts your tribe',
    'Lost in the music, found in the sound',
    'Life is better with headphones on',
    'Where words fail, music speaks',
    'Music is life itself',
  ];

  late String _currentQuote;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[DateTime.now().minute % _quotes.length];
    _quoteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentQuote = _quotes[Random().nextInt(_quotes.length)];
      });
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);
    final playback = ref.watch(playbackProvider);
    final history = ref.watch(historyProvider);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: res.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: res.hp(6)),
            _buildHeader(context, res, _currentQuote),
            SizedBox(height: res.hp(2.5)),
            _buildWeeklyChart(context, res),
            SizedBox(height: res.hp(2.5)),
            _buildStatsRow(context, res),
            if (playback.currentSong != null) ...[
              SizedBox(height: res.hp(2.5)),
              _buildNowPlayingCard(context, res, playback),
            ],
            SizedBox(height: res.hp(2.5)),
            Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: res.hp(1.5)),
            if (history.isEmpty)
              Text(
                'No songs played yet. Start listening!',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...history.take(5).map(
                (song) => SongCard(
                  song: song,
                  showFavorite: false,
                  playlist: history.take(5).toList(),
                ),
              ),
            SizedBox(height: res.hp(22)),
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              quote,
              key: ValueKey(quote),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: res.sp(26),
                fontWeight: FontWeight.bold,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        SizedBox(width: res.wp(4)),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(res.wp(3)),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: res.sp(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Responsive res) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayIndex = DateTime.now().weekday - 1;
    // Data dummy for now, can be persisted in future
    final data = [2, 5, 3, 8, 4, 0, 0];
    final maxData = data.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(4)),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stats',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: res.hp(2)),
          SizedBox(
            height: res.hp(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final height = maxData > 0
                    ? (data[i] / maxData) * 100
                    : 0.0;
                final isToday = i == dayIndex;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: res.wp(1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            height: height.clamp(4.0, max(4.0, res.hp(8))),
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? LinearGradient(
                                      colors: AppTheme.gradientColors,
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                              borderRadius: BorderRadius.circular(res.wp(1)),
                            ),
                          ),
                        ),
                        SizedBox(height: res.hp(0.8)),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: res.sp(10),
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

  Widget _buildStatsRow(BuildContext context, Responsive res) {
    final favorites = ref.watch(favoritesProvider);
    final songs = ref.watch(songsProvider);

    return Row(
      children: [
        _StatCard(
          res: res,
          icon: Icons.access_time_rounded,
          label: 'Listening',
          value: '0h 0m',
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: res.wp(2.5)),
        _StatCard(
          res: res,
          icon: Icons.favorite_rounded,
          label: 'Favorites',
          value: '${favorites.length} songs',
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(width: res.wp(2.5)),
        _StatCard(
          res: res,
          svgAsset: 'assets/app_logo.svg',
          label: 'Total',
          value: '${songs.length}',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, Responsive res, PlaybackState playback) {
    final currentSong = playback.currentSong;
    if (currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(res.wp(3.5)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(res.wp(4)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: res.wp(11),
              height: res.wp(11),
              padding: EdgeInsets.all(res.wp(2)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(res.wp(3)),
                gradient: LinearGradient(colors: AppTheme.gradientColors),
              ),
              child: SvgPicture.asset(
                'assets/app_logo.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: res.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: res.sp(13),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                playback.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: res.sp(40),
              ),
              onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Responsive res;
  final IconData? icon;
  final String label;
  final String value;
  final Color color;
  final String? svgAsset;

  const _StatCard({
    required this.res,
    this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.svgAsset,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(res.wp(4)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: res.sp(22),
                height: res.sp(22),
              )
            else
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: res.sp(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
