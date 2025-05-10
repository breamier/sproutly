import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  String plantName;
  Timestamp addedOn;
  String type;

  Plant({required this.plantName, required this.addedOn, required this.type});

  Plant.fromJson(Map<String, Object?> json)
    : this(
        plantName: json['plantName']! as String,
        addedOn: json['addedOn']! as Timestamp,
        type: json['type']! as String,
      );

  Plant copyWith({String? plantName, Timestamp? addedOn, String? type}) {
    return Plant(
      plantName: plantName ?? this.plantName,
      addedOn: addedOn ?? this.addedOn,
      type: type ?? this.type,
    );
  }

  Map<String, Object?> toJson() {
    return {'plantName': plantName, 'addedOn': addedOn, 'type': type};
  }
}
