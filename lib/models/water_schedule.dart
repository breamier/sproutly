// import 'package:flutter/material.dart';

// class WateringSchedule {
//   final List<int> selectedWeekdays; // 1=Monday, 7=Sunday
//   final TimeOfDay wateringTime;
//   final String plantId;

//   WateringSchedule({
//     required this.selectedWeekdays,
//     required this.wateringTime,
//     required this.plantId,
//   }) : assert(plantId.isNotEmpty, 'Plant ID cannot be empty'),
//        assert(selectedWeekdays.isNotEmpty, 'At least one day must be selected');

//   // Convert to map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'selectedWeekdays': selectedWeekdays,
//       'hour': wateringTime.hour,
//       'minute': wateringTime.minute,
//       'plantId': plantId,
//     };
//   }

//   // In water_schedule.dart
//   factory WateringSchedule.fromFirestore(Map<String, dynamic> map) {
//     return WateringSchedule(
//       selectedWeekdays: List<int>.from(map['selectedWeekdays'] ?? []),
//       wateringTime: TimeOfDay(
//         hour: map['hour'] ?? 9, // Default to 9 AM if null
//         minute: map['minute'] ?? 0,
//       ),
//       plantId: map['plantId'] ?? '', // Empty string if null
//     );
//   }
// }
