//imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

//models
import '../models/water_schedule.dart';

//services
import '../services/notification_service.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'wateringSchedules';

  Future<void> saveSchedule(WateringSchedule schedule) async {
    final nextNotification = _calculateNextNotification(schedule);

    await _firestore.collection(_collectionPath).doc(schedule.plantId).set({
      'selectedWeekdays': schedule.selectedWeekdays,
      'hour': schedule.wateringTime.hour,
      'minute': schedule.wateringTime.minute,
      'plantId': schedule.plantId,
      'nextNotificationTime': nextNotification,
    });

    // after saving to firestore, schedule notifications
    await _scheduleNotifications(schedule);
  }

  Future<void> _scheduleNotifications(WateringSchedule schedule) async {
    final notiService = NotiService();
    await notiService.initNotification();
    await notiService.cancelAllNotifications();

    // test test
    debugPrint('Scheduling notifications for plant: ${schedule.plantId}');
    debugPrint('Selected weekdays: ${schedule.selectedWeekdays}');
    debugPrint('Watering time: ${schedule.wateringTime}');

    for (final weekday in schedule.selectedWeekdays) {
      await notiService.scheduleNotification(
        title: 'Watering Reminder',
        body: 'Time to water your ${schedule.plantId}!',
        hour: schedule.wateringTime.hour,
        minute: schedule.wateringTime.minute,
        weekday: weekday,
      );
    }
  }

  Future<WateringSchedule?> getSchedule(String plantId) async {
    final doc = await _firestore.collection(_collectionPath).doc(plantId).get();
    if (doc.exists) {
      return WateringSchedule.fromFirestore(doc.data()!);
    }
    return null;
  }

  Future<List<DocumentSnapshot>> getAllPlants() async {
    final snapshot = await _firestore.collection('plants').get();
    return snapshot.docs;
  }

  // calculate next notification time (same weekday next week)
  Timestamp _calculateNextNotification(WateringSchedule schedule) {
    tz.initializeTimeZones();
    final location = tz.local;
    final now = tz.TZDateTime.now(location);

    // find the selected weekday that matches the schedule
    for (final weekday in schedule.selectedWeekdays) {
      // calculate days until next occurrence of this weekday
      int daysToAdd = (weekday - now.weekday) % 7;
      daysToAdd = daysToAdd <= 0 ? daysToAdd + 7 : daysToAdd;

      final nextDate = now.add(Duration(days: daysToAdd));

      final scheduledTime = tz.TZDateTime(
        location,
        nextDate.year,
        nextDate.month,
        nextDate.day,
        schedule.wateringTime.hour,
        schedule.wateringTime.minute,
      );

      // verify the time hasn't passed today (if scheduling for today)
      if (scheduledTime.isAfter(now)) {
        return Timestamp.fromDate(scheduledTime);
      }
    }

    return Timestamp.fromDate(now.add(Duration(days: 7)));
  }

  Future<List<QueryDocumentSnapshot>> getActiveSchedules() async {
    final now = Timestamp.now();
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('nextNotificationTime', isGreaterThanOrEqualTo: now)
        .get();
    return snapshot.docs;
  }
}
}

