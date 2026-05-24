import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionHeader(context, 'Music Library'),
            _buildMenuTile(
              context,
              icon: Icons.audio_file_rounded,
              title: 'Pick Audio Files',
              subtitle: 'Select MP3, WAV, FLAC files from storage',
              trailing: provider.isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : null,
              onTap: provider.isScanning
                  ? null
                  : () => provider.pickAudioFiles(),
            ),
            _buildMenuTile(
              context,
              icon: Icons.storage_rounded,
              title: 'Quick Scan',
              subtitle: 'Auto-scan Music & Download folders',
              trailing: provider.isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : null,
              onTap: provider.isScanning
                  ? null
                  : () => provider.scanDefaultDirectories(),
            ),
            const Divider(
              color: Colors.white10,
              height: 32,
              indent: 20,
              endIndent: 20,
            ),
            _buildSectionHeader(context, 'Library'),
            _buildMenuTile(
              context,
              icon: Icons.delete_sweep_rounded,
              title: 'Clear Library',
              subtitle: 'Remove all scanned songs',
              titleColor: const Color(0xFFEF4444),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Clear Library?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'All scanned songs will be removed. You can scan again later.',
                      style: TextStyle(color: Colors.white60),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<SongProvider>().clearSongs();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Info'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Melophile v1.0.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF06B6D4),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF06B6D4), size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: trailing ??
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
              ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
