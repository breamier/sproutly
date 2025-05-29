import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String plantName;
  final String water;
  final String sunlight;
  final String careLevel;
  final Timestamp addedOn;
  final String? type;
  final String? img;

  Plant({
    required this.id,
    required this.plantName,
    required this.water,
    required this.sunlight,
    required this.careLevel,
    required this.addedOn,
    this.type,
    this.img,
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
      water: json['water'] as String? ?? '',
      img: json['img'] as String? ?? '',
      sunlight: json['sunlight'] as String? ?? '',
      careLevel: json['careLevel'] as String? ?? '',
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
      'water': water,
      'sunlight': sunlight,
      'careLevel': careLevel,
      'addedOn': addedOn,
      if (type != null) 'type': type,
      if (img != null) 'img': img,
    };
  }

  // Add this copyWith method
  Plant copyWith({
    String? id,
    String? plantName,
    String? water,
    String? sunlight,
    String? careLevel,
    Timestamp? addedOn,
    String? type,
    String? img,
  }) {
    return Plant(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      water: water ?? this.water,
      sunlight: sunlight ?? this.sunlight,
      careLevel: careLevel ?? this.careLevel,
      addedOn: addedOn ?? this.addedOn,
      type: type ?? this.type,
      img: img ?? this.img,
    );
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
