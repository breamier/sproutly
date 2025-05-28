import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sproutly/models/plant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sproutly/models/plant_issue.dart';

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
          fromFirestore:
              (snapshots, _) => Plant.fromJson(snapshots.data()!, snapshots.id),
          toFirestore: (plant, _) => plant.toJson(),
        );
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
          fromFirestore:
              (snap, _) => PlantIssue.fromJson(snap.data()!, snap.id),
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

  void updatePlant(String plantId, Plant plant) {
    _plantsRef.doc(plantId).update(plant.toJson());
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

  // fetching all plants-categories values in firestore
  Future<List<String>> getDropdownOptions(String fieldPath) async {
    try {
      final doc =
          await _firestore
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
}
