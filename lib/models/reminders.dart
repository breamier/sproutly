import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String plantId;
  final String plantName;
  final DateTime reminderDate;
  final String reminderType; // water, rotate, check_light, check_health
  final bool completed;
  final int?
  notificationId; // track notification id (if user disable notification, it will disable all through id)

  Reminder({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.reminderDate,
    required this.reminderType,
    this.completed = false,
    this.notificationId,
  });

  factory Reminder.fromMap(Map<String, dynamic> data, String documentId) {
    return Reminder(
      id: documentId,
      plantId: data['plant_id'] ?? '',
      plantName: data['plant_name'] ?? '',
      reminderDate: (data['reminder_date'] as Timestamp).toDate(),
      reminderType: data['reminder_type'] ?? '',
      completed: data['completed'] ?? false,
      notificationId: data['notification_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plant_id': plantId,
      'plant_name': plantName,
      'reminder_date': Timestamp.fromDate(reminderDate),
      'reminder_type': reminderType,
      'completed': completed,
      if (notificationId != null) 'notification_id': notificationId,
    };
  }

  Reminder copyWith({
    String? id,
    String? plantId,
    String? plantName,
    DateTime? reminderDate,
    String? reminderType,
    bool? completed,
    int? notificationId,
  }) {
    return Reminder(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderType: reminderType ?? this.reminderType,
      completed: completed ?? this.completed,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
