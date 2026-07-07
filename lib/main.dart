import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database.dart';
import 'screens/home_shell.dart';
import 'services/daily_reminder_service.dart';
import 'theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget: permission requests/alarm scheduling shouldn't delay
  // showing the UI, and DailyReminderService is a no-op off Android.
  unawaited(DailyReminderService.init());
  runApp(const CritterDexApp());
}

class CritterDexApp extends StatelessWidget {
  const CritterDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => AppDatabase()..purgeExpiredBinItems(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..load(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeController = context.watch<ThemeController>();
          return MaterialApp(
            title: 'CritterDex',
            debugShowCheckedModeBanner: false,
            theme: themeController.themeData,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
