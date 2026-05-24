import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'screens/dashboard_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/list_song_screen.dart';
import 'widgets/floating_navbar.dart';
import 'widgets/now_playing_bar.dart';

class MelophileApp extends StatelessWidget {
  const MelophileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          PlaylistScreen(),
          ListSongScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NowPlayingBar(),
          FloatingNavbar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ],
      ),
    );
  }
}
