import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  Future<void> _openCustomize(
      BuildContext context, ThemeController controller) async {
    var seedColor = controller.customSeedColor;
    var brightness = controller.customBrightness;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Customize theme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<Brightness>(
                  segments: const [
                    ButtonSegment(value: Brightness.light, label: Text('Light')),
                    ButtonSegment(value: Brightness.dark, label: Text('Dark')),
                  ],
                  selected: {brightness},
                  onSelectionChanged: (s) =>
                      setDialogState(() => brightness = s.first),
                ),
                const SizedBox(height: 16),
                ColorPicker(
                  pickerColor: seedColor,
                  onColorChanged: (c) => setDialogState(() => seedColor = c),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Apply')),
          ],
        );
      }),
    );
    if (result == true) {
      await controller.setCustomScheme(seedColor, brightness);
    }
  }

  Future<Color?> _pickColor(
      BuildContext context, String title, Color initial) async {
    var picked = initial;
    return showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: picked,
              onColorChanged: (c) => setDialogState(() => picked = c),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(context).pop(picked),
                child: const Text('Apply')),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                for (final choice in AppThemeChoice.values)
                  if (choice != AppThemeChoice.custom)
                    RadioListTile<AppThemeChoice>(
                      title: Text(choice.label),
                      value: choice,
                      // ignore: deprecated_member_use
                      groupValue: themeController.choice,
                      // ignore: deprecated_member_use
                      onChanged: (v) {
                        if (v != null) themeController.setChoice(v);
                      },
                    ),
                RadioListTile<AppThemeChoice>(
                  title: const Text('Custom'),
                  subtitle: themeController.choice == AppThemeChoice.custom
                      ? null
                      : const Text('Tap Customize below to set one up'),
                  value: AppThemeChoice.custom,
                  // ignore: deprecated_member_use
                  groupValue: themeController.choice,
                  // ignore: deprecated_member_use
                  onChanged: (v) {
                    if (v == AppThemeChoice.custom) {
                      themeController.setCustomScheme(
                          themeController.customSeedColor,
                          themeController.customBrightness);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openCustomize(context, themeController),
            icon: const Icon(Icons.color_lens_outlined),
            label: const Text('Customize'),
          ),
          const SizedBox(height: 24),
          Text('Box & shelf colors', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeController.boxColor ??
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  title: const Text('Terrarium box color'),
                  subtitle: const Text('Default color for terrarium boxes on a shelf'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      if (themeController.boxColor != null)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset to theme default',
                          onPressed: () => themeController.setBoxColor(null),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Choose color',
                        onPressed: () async {
                          final picked = await _pickColor(
                              context,
                              'Terrarium box color',
                              themeController.boxColor ??
                                  Theme.of(context).colorScheme.primaryContainer);
                          if (picked != null) {
                            await themeController.setBoxColor(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeController.shelfColor ??
                        Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  title: const Text('Shelf color'),
                  subtitle: const Text('Background color of each shelf level'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      if (themeController.shelfColor != null)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset to theme default',
                          onPressed: () => themeController.setShelfColor(null),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Choose color',
                        onPressed: () async {
                          final picked = await _pickColor(
                              context,
                              'Shelf color',
                              themeController.shelfColor ??
                                  Theme.of(context).colorScheme.surfaceContainerLow);
                          if (picked != null) {
                            await themeController.setShelfColor(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
