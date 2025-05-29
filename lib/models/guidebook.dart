// Model for Plant Guidebook
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideBook {
  final String id;
  final String name;
  final String description;
  final String light;
  final String plantType;
  final String plantImage;
  final List<String> careTip;
  final String water;

  GuideBook({
    required this.id,
    required this.name,
    required this.description,
    required this.light,
    required this.plantType,
    required this.plantImage,
    required this.careTip,
    required this.water,
  });

  factory GuideBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // check if care_tip exists and is not null
    final tipsRaw = data['care_tip'];
    List<String> tips = [];
    if (tipsRaw != null) {
      if (tipsRaw is List) {
        tips = tipsRaw.map((e) => e.toString()).toList();
      } else if (tipsRaw is String) {
        tips = [tipsRaw];
      }
    }

    return GuideBook(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      light: data['light'] ?? '',
      plantType: data['plantType'] ?? '',
      plantImage: data['plant_image'] ?? '',
      careTip: tips,
      water: data['water'] ?? '',
    );
  }
}

// fetching Guidebook plant per document
class PlantGuidebook {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'guidebook';

  // fetch all plants in the guidebook collection
  Future<List<GuideBook>> fetchAllPlants() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => GuideBook.fromFirestore(doc)).toList();
  }
}
