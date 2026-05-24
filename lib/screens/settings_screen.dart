import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../providers/song_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);
    final provider = context.watch<SongProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: res.sp(18)),
        ),
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
              trailing: provider.isScanning
                  ? SizedBox(
                      width: res.sp(20),
                      height: res.sp(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : null,
              onTap: provider.isScanning
                  ? null
                  : () => _pickFolder(context, provider),
            ),
            _buildMenuTile(
              context,
              res: res,
              icon: Icons.storage_rounded,
              title: 'Quick Scan',
              subtitle: 'Auto-scan Music & Download folders',
              trailing: provider.isScanning
                  ? SizedBox(
                      width: res.sp(20),
                      height: res.sp(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : null,
              onTap: provider.isScanning
                  ? null
                  : () => provider.scanDefaultDirectories(),
            ),
            Divider(
              color: Colors.white10,
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
              titleColor: const Color(0xFFEF4444),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(res.wp(4)),
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
            SizedBox(height: res.hp(3)),
            _buildSectionHeader(context, res, 'Info'),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: res.wp(5),
                vertical: res.hp(1),
              ),
              child: Text(
                'Melophile v1.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: res.sp(14),
                ),
              ),
            ),
            SizedBox(height: res.hp(4)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context, SongProvider provider) async {
    if (Platform.isAndroid) {
      final granted = await Permission.manageExternalStorage.isGranted;
      if (!granted) {
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Storage Permission Needed',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: const Text(
              'Melophile needs "Manage all files" permission to scan your music folders. '
              'Please enable it in Settings.',
              style: TextStyle(color: Colors.white60),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(color: Color(0xFF06B6D4)),
                ),
              ),
            ],
          ),
        );

        if (shouldOpen == true) {
          await openAppSettings();
        }
        return;
      }
    }

    provider.pickAndScanFolder();
  }

  Widget _buildSectionHeader(BuildContext context, Responsive res, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: res.wp(5),
        vertical: res.hp(1.5),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF06B6D4),
          fontWeight: FontWeight.w600,
          fontSize: res.sp(16),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(res.wp(3)),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            width: res.wp(9),
            height: res.wp(9),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(res.wp(3)),
            ),
            child: Icon(icon, color: const Color(0xFF06B6D4), size: res.sp(22)),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.white,
              fontSize: res.sp(15),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: res.sp(12),
                  ),
                )
              : null,
          trailing: trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: res.sp(22),
              ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(res.wp(3)),
          ),
        ),
      ),
    );
  }
}
