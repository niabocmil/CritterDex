import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../models/reminders.dart';

const _alarmId = 8001;
const _prefsKey = 'daily_reminder_notifications_enabled';
const _channelId = 'daily_reminders';
const _channelName = 'Daily reminders';
const _channelDescription =
    "Once-a-day summary of anything due for replenishing or a breeding follow-up.";

/// Drives the once-daily "anything due today?" system notification.
/// Android-only (see the platform check in [init]/[setEnabled]).
///
/// The alarm is scheduled via [android_alarm_manager_plus], which keeps a
/// background isolate around to run [_dailyCheckCallback] roughly once a
/// day. Scheduling is deliberately inexact (`exact: false`, the default) —
/// an exact daily alarm needs the user to separately grant the "Alarms &
/// reminders" special permission in system settings (mandatory on Android
/// 14+, and this plugin doesn't offer a way to request it), which felt like
/// too much friction for a soft "around 8am" daily digest. In practice
/// Android may shift the actual fire time by anywhere from minutes to under
/// an hour to batch with other apps' alarms, especially under Doze.
///
/// Nothing is ever pre-baked at scheduling time: the callback re-opens the
/// database fresh each time it fires and only actually shows a notification
/// if something is genuinely due or overdue *today*.
class DailyReminderService {
  DailyReminderService._();

  /// Call once at app startup. Requests the notification permission (a
  /// no-op if already granted/denied), initializes the alarm manager, and
  /// (re)schedules the daily alarm if the user has it enabled (default on).
  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await AndroidAlarmManager.initialize();
    if (await isEnabled()) {
      await _schedule();
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  }

  /// Flips the daily notification on/off, persists the choice, and
  /// schedules/cancels the underlying alarm to match.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
    if (!Platform.isAndroid) return;
    if (enabled) {
      await _schedule();
    } else {
      await AndroidAlarmManager.cancel(_alarmId);
    }
  }

  static Future<void> _schedule() async {
    final now = DateTime.now();
    var firstRun = DateTime(now.year, now.month, now.day, 8);
    if (!firstRun.isAfter(now)) {
      firstRun = firstRun.add(const Duration(days: 1));
    }
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      _alarmId,
      _dailyCheckCallback,
      startAt: firstRun,
      allowWhileIdle: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}

/// Runs in a separate background isolate spun up by android_alarm_manager_plus
/// — it shares no memory/state with the running app (if any), so it opens
/// its own database connection and its own notifications-plugin instance.
@pragma('vm:entry-point')
Future<void> _dailyCheckCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  try {
    final specimens = await db.getAllSpecimens();
    final terrariums = await db.getAllTerrariums();
    final shelves = await db.getAllShelves();
    final tools = await db.getAllTools();
    final breedingEvents = await db.watchAllBreedingEvents().first;
    final breedingReminders = await db.watchActiveBreedingReminders().first;

    final today = DateUtils.dateOnly(DateTime.now());
    final dueToday = computeReminders(
      specimens: specimens,
      terrariums: terrariums,
      shelves: shelves,
      tools: tools,
      breedingEvents: breedingEvents,
      breedingReminders: breedingReminders,
    ).where((r) => r.isMissed || r.dueDate == today).toList();

    if (dueToday.isEmpty) return;

    final replenishCount =
        dueToday.where((r) => r.source == ReminderSource.replenish).length;
    final breedingCount =
        dueToday.where((r) => r.source == ReminderSource.breeding).length;
    final growthCount =
        dueToday.where((r) => r.source == ReminderSource.growth).length;
    final parts = [
      if (replenishCount > 0)
        '$replenishCount terrarium${replenishCount == 1 ? '' : 's'} to replenish',
      if (breedingCount > 0)
        '$breedingCount breeding reminder${breedingCount == 1 ? '' : 's'}',
      if (growthCount > 0)
        '$growthCount growth check-in${growthCount == 1 ? '' : 's'}',
    ];

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
    ));
    await plugin.show(
      id: _alarmId,
      title: '${dueToday.length} thing${dueToday.length == 1 ? '' : 's'} due today',
      body: parts.join(' · '),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          priority: Priority.high,
        ),
      ),
    );
  } finally {
    await db.close();
  }
}
