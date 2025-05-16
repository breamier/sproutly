import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sproutly/models/plant.dart';

const String PLANT_COLLECTION_REF = "plants";
const String plantCategoriesRef = "plants-categories";
const String categoriesIdRef = "TJLhPyxbEG4wXt5aSRFg";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _plantsRef;

  DatabaseService() {
    _plantsRef = _firestore
        .collection(PLANT_COLLECTION_REF)
        .withConverter<Plant>(
          fromFirestore: (snapshots, _) =>
              Plant.fromJson(snapshots.data()!, snapshots.id),
          toFirestore: (plant, _) => plant.toJson(),
        );
  }

  Stream<QuerySnapshot> getPlants() {
    return _plantsRef.snapshots();
  }

  void addPlant(Plant plant) async {
    _plantsRef.add(plant);
  }

  void updatePlant(String plantId, Plant plant) {
    _plantsRef.doc(plantId).update(plant.toJson());
  }

  void deletePlant(String plantId) {
    _plantsRef.doc(plantId).delete();
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
}
