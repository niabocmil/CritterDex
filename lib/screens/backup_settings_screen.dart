import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/backup_service.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _busy = false;

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportBackup(AppDatabase db) async {
    final service = BackupService(db);
    final file = await service.exportBackup();
    await service.shareBackup(file);
  }

  Future<void> _importBackup(AppDatabase db) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace all data?'),
        content: const Text(
            'Importing a backup permanently replaces every specimen, '
            'breeding event, shelf and terrarium currently in the app with '
            'the contents of the backup file. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Replace everything')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    await BackupService(db).importBackup(File(path));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Backup restored')));
    }
  }

  Future<void> _eraseAllData(AppDatabase db) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erase all data?'),
        content: const Text(
            'This permanently deletes every specimen, terrarium, shelf, tool, '
            'breeding event and activity log in the app, along with all photos. '
            'This cannot be undone. Consider exporting a backup first.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: scheme.error, foregroundColor: scheme.onError),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Erase everything')),
        ],
      ),
    );
    if (confirmed != true) return;

    await BackupService(db).eraseAllData();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All data erased')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.5 : 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: const Text('Export backup'),
                      subtitle: const Text(
                          'Save a .zip with all data and photos to share or store elsewhere'),
                      onTap: () => _runBusy(() => _exportBackup(db)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Import backup'),
                      subtitle: const Text('Replace everything with a backup .zip'),
                      onTap: () => _runBusy(() => _importBackup(db)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.delete_forever,
                          color: Theme.of(context).colorScheme.error),
                      title: Text('Erase all data',
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.error)),
                      subtitle: const Text(
                          'Permanently delete everything in the app — no undo'),
                      onTap: () => _runBusy(() => _eraseAllData(db)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Android's automatic backup to your Google account stays on regardless — this is an additional, manual option.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
