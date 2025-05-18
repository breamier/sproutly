import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String plantName;
  final String date;
  final String time;
  final String water;
  final String sunlight;
  final String careLevel;
  final String? lifespan;
  final String? waterStorage;
  final Timestamp addedOn;
  final String? type;

  Plant({
    required this.id,
    required this.plantName,
    required this.date,
    required this.time,
    required this.water,
    required this.sunlight,
    required this.careLevel,
    this.lifespan,
    this.waterStorage,
    required this.addedOn,
    this.type,
  });

  factory Plant.fromJson(Map<String, Object?> json, String id) {
    Timestamp timestamp;
    try {
      timestamp = _parseAddedOn(json['addedOn']);
    } catch (e) {
      timestamp = Timestamp.now();
    }

    return Plant(
      id: id,
      plantName: json['plantName'] as String? ?? 'Unknown Plant',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      water: json['water'] as String? ?? '',
      sunlight: json['sunlight'] as String? ?? '',
      careLevel: json['careLevel'] as String? ?? '',
      lifespan: json['lifespan'] as String?,
      waterStorage: json['waterStorage'] as String?,
      addedOn: timestamp,
      type: json['type'] as String?,
    );
  }

  static Timestamp _parseAddedOn(dynamic addedOn) {
    if (addedOn is Timestamp) {
      return addedOn;
    } else if (addedOn is String) {
      try {
        final dateTime = DateTime.tryParse(addedOn);
        if (dateTime != null) {
          return Timestamp.fromDate(dateTime);
        }

        final format = DateFormat("MMMM d, y 'at' h:mm:ss a 'UTC'Z");
        final parsedDate = format.parse(addedOn.replaceAll('UTC+', 'UTC+'));
        return Timestamp.fromDate(parsedDate);
      } catch (e) {
        throw FormatException('Could not parse date: $addedOn');
      }
    }
    throw ArgumentError('addedOn must be either Timestamp or String');
  }

  Map<String, Object?> toJson() {
    return {
      'plantName': plantName,
      'date': date,
      'time': time,
      'water': water,
      'sunlight': sunlight,
      'careLevel': careLevel,
      if (lifespan != null) 'lifespan': lifespan,
      if (waterStorage != null) 'waterStorage': waterStorage,
      'addedOn': addedOn,
      if (type != null) 'type': type,
    };
  }
}

class Plants {
  final List<Plant> plantList;

  Plants({required this.plantList});

  factory Plants.fromJson(List<Map<String, Object?>> json) {
    return Plants(
      plantList: json
          .asMap()
          .entries
          .map((e) => Plant.fromJson(e.value, e.key.toString()))
          .toList(),
    );
  }
}