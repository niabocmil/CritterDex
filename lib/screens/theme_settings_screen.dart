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
        ],
      ),
    );
  }
}
