import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// models
import 'package:sproutly/models/plant_issue.dart';
import 'package:sproutly/models/plant_journal_entry.dart';
import 'package:sproutly/models/plant.dart';
import '../models/reminders.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../cloudinary/delete_image.dart';

const String USERS_COLLECTION_REF = "Users";
const String plantCategoriesRef = "plants-categories";
const String categoriesIdRef = "TJLhPyxbEG4wXt5aSRFg";

class DatabaseService {
  // final String userId;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Plant> get _plantsRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return _firestore
        .collection(USERS_COLLECTION_REF)
        .doc(user.uid)
        .collection('plants')
        .withConverter<Plant>(
          fromFirestore: (snapshots, _) =>
              Plant.fromJson(snapshots.data()!, snapshots.id),
          toFirestore: (plant, _) => plant.toJson(),
        );
  }

  CollectionReference<Map<String, dynamic>> get _remindersRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return _firestore
        .collection(USERS_COLLECTION_REF)
        .doc(user.uid)
        .collection('reminders');
  }

  // DatabaseService() {
  //   if (user == null) {
  //     throw Exception('No user logged in');
  //   }
  //   _plantsRef = _firestore
  //       .collection(USERS_COLLECTION_REF)
  //       .doc(userId)
  //       .collection('plants')
  //       .withConverter<Plant>(
  //         fromFirestore:
  //             (snapshots, _) => Plant.fromJson(snapshots.data()!, snapshots.id),
  //         toFirestore: (plant, _) => plant.toJson(),
  //       );
  // }
  CollectionReference<PlantIssue> _plantIssueRef(String plantId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return _firestore
        .collection(USERS_COLLECTION_REF)
        .doc(user.uid)
        .collection('plants')
        .doc(plantId)
        .collection('plant_issues')
        .withConverter<PlantIssue>(
          fromFirestore: (snap, _) =>
              PlantIssue.fromJson(snap.data()!, snap.id),
          toFirestore: (issue, _) => issue.toJson(),
        );
  }

  CollectionReference<PlantJournalEntry> _plantJournalRef(String plantId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return _firestore
        .collection(USERS_COLLECTION_REF)
        .doc(user.uid)
        .collection('plants')
        .doc(plantId)
        .collection('plant_journal')
        .withConverter<PlantJournalEntry>(
          fromFirestore: (snap, _) =>
              PlantJournalEntry.fromJson(snap.data()!, snap.id),
          toFirestore: (issue, _) => issue.toJson(),
        );
  }

  // ----------------------- PLANTS -----------------------
  Stream<QuerySnapshot> getPlants() {
    return _plantsRef.snapshots();
  }

  Future<void> addPlant(Plant plant) async {
    _plantsRef.add(plant);
  }

  Future<void> updatePlant(String userId, String plantId, Plant plant) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .update(plant.toJson());
  }

  void deletePlant(String plantId) {
    _plantsRef.doc(plantId).delete();
  }

  Future<Plant?> getPlantById(String plantId) async {
    final doc = await _plantsRef.doc(plantId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // ----------------------- PLANT ISSUES -----------------------

  Future<void> addPlantIssue(String plantId, PlantIssue issue) async {
    await _plantIssueRef(plantId).add(issue);
  }

  Stream<QuerySnapshot<PlantIssue>> getPlantIssues(String plantId) {
    return _plantIssueRef(plantId).snapshots();
  }

  Future<void> updatePlantIssue(
    String plantId,
    String issueId,
    PlantIssue issue,
  ) async {
    await _plantIssueRef(plantId).doc(issueId).update(issue.toJson());
  }

  Future<void> deletePlantIssue(String plantId, String issueId) async {
    await _plantIssueRef(plantId).doc(issueId).delete();
  }

  // ----------------------- GROWTH JOURNAL -----------------------
  Future<void> addJournalEntry(
    String plantId,
    PlantJournalEntry plantJournalEntry,
  ) async {
    await _plantJournalRef(plantId).add(plantJournalEntry);
  }

  Stream<QuerySnapshot<PlantJournalEntry>> getJournalEntries(String plantId) {
    return _plantJournalRef(plantId).snapshots();
  }

  Future<void> updateJournalEntry(
    String plantId,
    String journalId,
    PlantJournalEntry updatedEntry,
  ) async {
    await _plantJournalRef(
      plantId,
    ).doc(journalId).update(updatedEntry.toJson());
  }

  // fetching all plants-categories values in firestore
  Future<List<String>> getDropdownOptions(String fieldPath) async {
    try {
      final doc = await _firestore
          .collection(plantCategoriesRef)
          .doc(categoriesIdRef)
          .get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final categories = data['categories'] as Map<String, dynamic>?;
      if (categories == null) return [];

      // water-level, sunlight-level, care-level
      if (categories.containsKey(fieldPath)) {
        final options = categories[fieldPath] as List<dynamic>?;
        return options?.map((e) => e.toString()).toList() ?? [];
      }

      // plant_types fields since nested
      // didn't include lifespan yet since unsure how the types of plant will work because maraming categories din ng types :')
      if (fieldPath == 'lifespan' ||
          fieldPath == 'water-storage-and-adaptation') {
        final plantTypes = categories['plant_types'] as Map<String, dynamic>?;
        final options = plantTypes?[fieldPath] as List<dynamic>?;
        return options?.map((e) => e.toString()).toList() ?? [];
      }

      return [];
    } catch (e) {
      print('Error fetching $fieldPath: $e');
      return [];
    }
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    await FirebaseFirestore.instance.collection('images').add({
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // plant profile services

  Future<void> updatePlantImage(
    String userId,
    String plantId,
    String? imgUrl,
  ) async {
    print(
      'Updating Firestore image. userId: $userId, plantId: $plantId, imgUrl: $imgUrl',
    );
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('plants')
          .doc(plantId)
          .update({'img': imgUrl});
      print('Firestore image update succeeded');
    } catch (e) {
      print('Firestore image update failed: $e');
    }
  }

  Future<Plant?> getPlantProfileById(String userId, String plantId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .get();
    if (doc.exists && doc.data() != null) {
      return Plant.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  // delete user data

  Future<void> deleteAllUserPlants() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    final plantsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('plants');

    final plantDocs = await plantsRef.get();

    for (var plantDoc in plantDocs.docs) {
      final plantData = plantDoc.data();
      // Delete plant's image in Cloudinary
      final plantImgUrl = plantData['img'] as String?;
      if (plantImgUrl != null && plantImgUrl.isNotEmpty) {
        try {
          final publicId = extractCloudinaryPublicId(plantImgUrl);
          await deleteImageFromCloudinary(publicId);
        } catch (e) {
          print("Failed to delete plant image: $e");
        }
      }

      // Delete all plant_issues subcollection docs
      final issuesRef = plantDoc.reference.collection('plant_issues');
      final issuesSnapshot = await issuesRef.get();
      for (var issueDoc in issuesSnapshot.docs) {
        await issueDoc.reference.delete();
      }

      // Delete all plant_journal subcollection
      final journalRef = plantDoc.reference.collection('plant_journal');
      final journalSnapshot = await journalRef.get();
      for (var journalDoc in journalSnapshot.docs) {
        await journalDoc.reference.delete();
      }

      // Delete the plant doc itself
      await plantDoc.reference.delete();
      debugPrint('Deleted plant: ${plantDoc.id}');
    }
  }

  String extractCloudinaryPublicId(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      String filename = segments.last;
      int dot = filename.lastIndexOf('.');
      if (dot > 0) {
        return filename.substring(0, dot);
      } else {
        return filename;
      }
    }
    throw Exception("Could not extract publicId from URL");
  }

  // reminders services ayyeee
  Future<void> addReminder(Reminder reminder) async {
    await _remindersRef.add(reminder.toMap());
  }

  Stream<List<Reminder>> getReminders() {
    return _remindersRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  //TODO
  Future<void> updateReminder(String reminderId, Reminder reminder) async {
    await _remindersRef.doc(reminderId).update(reminder.toMap());
  }

  //TODO
  Future<void> deleteReminder(String reminderId) async {
    await _remindersRef.doc(reminderId).delete();
  }
}
