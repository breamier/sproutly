import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Request permissions (for Android 13+)
    if (Platform.isAndroid) {
      final androidPlugin =
          notificationPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidPlugin?.requestNotificationsPermission();
    }

    // prepare android init settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // prepare ios settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'plant_watering_channel',
        'Plant Watering Reminders',
        channelDescription: 'Channel for plant watering schedule notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await notificationPlugin.show(id, title, body, notificationDetails());
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          notificationPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin =
          notificationPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return true;
    }
    return false;
  }

  Future<void> scheduleNotification({
    int id = 0,
    required String title,
    required String body,
    required int hour,
    required int minute,
    int? weekday,
  }) async {
    try {
      if (!_isInitialized) {
        await initNotification();
      }

      // request permissions if not granted
      if (!await _requestPermissions()) {
        debugPrint('Notification permissions not granted');
        return;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (weekday != null) {
        // find next occurrence of this weekday
        while (scheduledDate.weekday != weekday ||
            scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }

      debugPrint('Scheduling notification for: $scheduledDate');

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        matchDateTimeComponents:
            weekday != null
                ? DateTimeComponents.dayOfWeekAndTime
                : DateTimeComponents.time,
      );

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
}
