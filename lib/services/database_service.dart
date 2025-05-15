import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sproutly/models/plant.dart';

const String PLANT_COLLECTION_REF = "plants";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _plantsRef;

  DatabaseService() {
    _plantsRef = _firestore
        .collection(PLANT_COLLECTION_REF)
        .withConverter<Plant>(
          fromFirestore: (snapshots, _) => Plant.fromJson(snapshots.data()!),
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
}
