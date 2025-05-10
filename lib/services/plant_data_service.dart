import 'package:sproutly/models/plant_category_model.dart';

class PlantDataService {
  static final PlantDataService _instance = PlantDataService._internal();
  
  factory PlantDataService() {
    return _instance;
  }
  
  PlantDataService._internal();
  
  List<PlantCategory> getDefaultCategories() {
    return const [
      PlantCategory(
        title: 'Cactus',
        imageName: 'cactus.png',
        description: 'A cactus is a member of the plant family Cactaceae, a family comprising about 127 genera with some 1750 known species of the order Caryophyllales.',
        careTip: 'Water sparingly and provide plenty of sunlight. Don\'t overwater as cacti store water in their stems.'
      ),
      PlantCategory(
        title: 'Herbs',
        imageName: 'herbs.png',
        description: 'Herbs are plants with savory or aromatic properties that are used for flavoring food, in medicine, or as fragrances.',
        careTip: 'Most herbs need at least 6 hours of sunlight per day. Water when the soil feels dry to the touch.'
      ),
      PlantCategory(
        title: 'Trees',
        imageName: 'trees.png',
        description: 'Trees are perennial plants with an elongated stem, or trunk, supporting branches and leaves in most species.',
        careTip: 'Young trees need regular watering. Fertilize in early spring and maintain proper pruning for healthy growth.'
      ),
      PlantCategory(
        title: 'Shrubs',
        imageName: 'shrubs.png',
        description: 'Shrubs are woody plants with multiple stems and are generally shorter than trees, usually under 6m tall.',
        careTip: 'Water deeply but infrequently to encourage deep root growth. Prune after flowering to maintain shape.'
      ),
      PlantCategory(
        title: 'Succulent',
        imageName: 'succulent.png',
        description: 'Succulents are plants that have some parts that are more than normally thickened and fleshy, usually to retain water in arid climates or soil conditions.',
        careTip: 'Allow soil to dry completely between waterings. Provide bright, indirect sunlight and well-draining soil mixture.'
      ),
    ];
  }

  PlantCategory? getCategoryByTitle(String title) {
    try {
      return getDefaultCategories().firstWhere(
        (category) => category.title.toLowerCase() == title.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }
  
  List<PlantCategory> searchCategories(String query) {
    if (query.isEmpty) return getDefaultCategories();
    
    return getDefaultCategories().where(
      (category) => category.title.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}