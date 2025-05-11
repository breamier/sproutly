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
    return Plant(
      id: id,
      plantName: json['plantName']! as String,
      date: json['date']! as String,
      time: json['time']! as String,
      water: json['water']! as String,
      sunlight: json['sunlight']! as String,
      careLevel: json['careLevel']! as String,
      lifespan: json['lifespan'] as String?,
      waterStorage: json['waterStorage'] as String?,
      addedOn: json['addedOn']! as Timestamp,
      type: json['type'] as String?,
    );
  }

  Plant copyWith({
    String? id,
    String? plantName,
    String? date,
    String? time,
    String? water,
    String? sunlight,
    String? careLevel,
    String? lifespan,
    String? waterStorage,
    Timestamp? addedOn,
    String? type,
  }) {
    return Plant(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      date: date ?? this.date,
      time: time ?? this.time,
      water: water ?? this.water,
      sunlight: sunlight ?? this.sunlight,
      careLevel: careLevel ?? this.careLevel,
      lifespan: lifespan ?? this.lifespan,
      waterStorage: waterStorage ?? this.waterStorage,
      addedOn: addedOn ?? this.addedOn,
      type: type ?? this.type,
    );
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
