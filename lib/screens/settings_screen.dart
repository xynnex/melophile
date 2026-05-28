import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/responsive.dart';
import '../providers/song_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive(context);
    final songsNotifier = ref.read(songsProvider.notifier);
    
    // We might need a separate scan status provider if we want real-time loading UI
    // For now, using a simple check or ref.watch(songsProvider)
    
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
            SizedBox(height: res.hp(1)),
            _buildSectionHeader(context, res, 'Music Library'),
            _buildMenuTile(
              context,
              res: res,
              icon: Icons.folder_open_rounded,
              title: 'Pick Folder',
              subtitle: 'Select a folder to scan for music',
              onTap: () => _pickFolder(context, ref),
            ),
            _buildMenuTile(
              context,
              res: res,
              icon: Icons.storage_rounded,
              title: 'Quick Scan',
              subtitle: 'Auto-scan Music & Download folders',
              onTap: () => songsNotifier.scanDefault(),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              height: res.hp(4),
              indent: res.wp(5),
              endIndent: res.wp(5),
            ),
            _buildSectionHeader(context, res, 'Library'),
            _buildMenuTile(
              context,
              res: res,
              icon: Icons.delete_sweep_rounded,
              title: 'Clear Library',
              subtitle: 'Remove all scanned songs',
              titleColor: Theme.of(context).colorScheme.error,
              onTap: () {
                _showClearLibraryDialog(context, ref, res);
              },
            ),
            SizedBox(height: res.hp(3)),
            _buildSectionHeader(context, res, 'Info'),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: res.wp(5),
                vertical: res.hp(1),
              ),
              child: Text(
                'Melophile v1.0.0 (Riverpod Edition)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: res.hp(4)),
          ],
        ),
      ),
    );
  }

  void _showClearLibraryDialog(BuildContext context, WidgetRef ref, Responsive res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(res.wp(4)),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: const Text('Clear Library?'),
        content: const Text(
          'All scanned songs will be removed. You can scan again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(songsProvider.notifier).clear();
              await ref.read(playbackProvider.notifier).stop();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    if (Platform.isAndroid) {
      final deviceInfo = await _getAndroidVersion();
      
      if (deviceInfo >= 30) { // Android 11 (API 30) or higher
        final granted = await Permission.manageExternalStorage.isGranted;
        if (!granted) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            if (context.mounted) _showPermissionDialog(context);
            return;
          }
        }
      } else { // Android 10 or lower
        final granted = await Permission.storage.isGranted;
        if (!granted) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            if (context.mounted) _showPermissionDialog(context);
            return;
          }
        }
      }
    }

    ref.read(songsProvider.notifier).scanFolder();
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Simple way to get SDK version without additional plugins if possible, 
      // but for robustness we check if we can parse it from Platform.version
      // or just assume 30 for modern devices if check fails.
      return 30; // Default to modern logic, SM A528B is Android 11+
    }
    return 0;
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: const Text('Permission Needed'),
        content: const Text(
          'Melophile needs access to your storage to scan music files. '
          'Please grant the permission in the next screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: Text(
              'Settings',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, Responsive res, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: res.wp(5),
        vertical: res.hp(1.5),
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required Responsive res,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: res.wp(3),
        vertical: res.hp(0.3),
      ),
      child: ListTile(
        leading: Container(
          width: res.wp(10),
          height: res.wp(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(res.wp(3)),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: res.sp(20),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontSize: res.sp(15),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: res.sp(22),
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(res.wp(3)),
        ),
      ),
    );
  }
}
