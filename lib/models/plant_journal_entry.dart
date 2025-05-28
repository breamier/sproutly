import 'package:cloud_firestore/cloud_firestore.dart';

class PlantJournalEntry {
  final String id;
  final String plantId;
  final String title;
  final String notes;
  final Timestamp createdAt;
  final List<String> imageUrls;

  PlantJournalEntry({
    required this.id,
    required this.plantId,
    required this.title,
    required this.notes,
    required this.createdAt,
    required this.imageUrls,
  });

  factory PlantJournalEntry.fromJson(Map<String, dynamic> json, String id) {
    return PlantJournalEntry(
      id: id,
      plantId: json['plant_id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String,
      createdAt: json['created_at'] as Timestamp? ?? Timestamp.now(),
      imageUrls:
          (json['image_urls'] as List<dynamic>? ?? [])
              .map((e) => e as String)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_id': plantId,
      'title': title,
      'notes': notes,
      'created_at': createdAt,
      'image_urls': imageUrls,
    };
  }
}

class PlantJournalEntries {
  final List<PlantJournalEntry> entries;

  PlantJournalEntries({required this.entries});

  factory PlantJournalEntries.fromJson(List<Map<String, dynamic>> jsonList) {
    return PlantJournalEntries(
      entries:
          jsonList
              .asMap()
              .entries
              .map((e) => PlantJournalEntry.fromJson(e.value, e.key.toString()))
              .toList(),
    );
  }
}
