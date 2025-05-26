import 'package:cloud_firestore/cloud_firestore.dart';

class PlantIssue {
  final String id;
  final String plantId;
  final String issueDescription;
  final bool resolved;
  final Timestamp createdAt;

  PlantIssue({
    required this.id,
    required this.plantId,
    required this.issueDescription,
    required this.resolved,
    required this.createdAt,
  });

  factory PlantIssue.fromJson(Map<String, dynamic> json, String id) {
    return PlantIssue(
      id: id,
      plantId: json['plant_id'] as String,
      issueDescription: json['issue_description'] as String,
      resolved: json['resolved'] as bool? ?? false,
      createdAt: json['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_id': plantId,
      'issue_description': issueDescription,
      'resolved': resolved,
      'created_at': createdAt,
    };
  }
}

class PlantIssues {
  final List<PlantIssue> issues;

  PlantIssues({required this.issues});

  factory PlantIssues.fromJson(List<Map<String, dynamic>> jsonList) {
    return PlantIssues(
      issues:
          jsonList
              .asMap()
              .entries
              .map((e) => PlantIssue.fromJson(e.value, e.key.toString()))
              .toList(),
    );
  }
}
