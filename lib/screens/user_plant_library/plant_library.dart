import 'package:flutter/material.dart';
import 'package:sproutly/screens/user_plant_library/plant_profile.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantLibraryScreen extends StatefulWidget {
  const PlantLibraryScreen({super.key});

  @override
  State<PlantLibraryScreen> createState() => _PlantLibraryScreenState();
}

class _PlantLibraryScreenState extends State<PlantLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> plantData = [
    {'name': 'Tulip', 'type': 'Plantae', 'image': 'assets/tulips.png'},
    {'name': 'Hibiscus', 'type': 'Type', 'image': 'assets/hibiscus.png'},
    {'name': 'Rose', 'type': 'Type', 'image': 'assets/rose.png'},
    {'name': 'Hyacinth', 'type': 'Type', 'image': 'assets/hyacinth.png'},
  ];

  List<Map<String, dynamic>> get filteredPlants {
    if (_searchQuery.isEmpty) {
      return plantData;
    }

    return plantData.where((plant) {
      final name = plant['name'].toString().toLowerCase();
      final type = plant['type'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || type.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color oliveTitleColor = Color(0xFF747822);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Your Plants',
                style: TextStyle(
                  fontFamily: 'Curvilingus',
                  fontSize: 38,
                  color: oliveTitleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8D5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: oliveTitleColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: oliveTitleColor),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Color(0xFF9A9D6B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.search,
                        color: oliveTitleColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Grid of plants
              Expanded(
                child: StreamBuilder(
                  stream: DatabaseService().getPlants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No plants found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: oliveTitleColor,
                          ),
                        ),
                      );
                    }

                    // Map Firestore docs to Plant objects
                    final List<Plant> plants = snapshot.data!.docs
                        .map<Plant>((doc) => doc.data() as Plant)
                        .where((plant) {
                          final name = plant.plantName.toLowerCase();
                          final type = (plant.type ?? '').toLowerCase();
                          final query = _searchQuery.toLowerCase();
                          return name.contains(query) || type.contains(query);
                        })
                        .toList();

                    if (plants.isEmpty) {
                      return Center(
                        child: Text(
                          'No plants match your search',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: oliveTitleColor,
                          ),
                        ),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.75,
                      children: _buildPlantItems(plants),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlantItems(List<Plant> plants) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return plants.map((plant) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlantProfileScreen(userId: userId, plantId: plant.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: plant.img != null && plant.img!.isNotEmpty
                    ? Image.network(plant.img!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.local_florist,
                          size: 60,
                          color: Color(0xFF747822),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plant.plantName,
              textAlign: TextAlign.center, 
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF747822),
              ),
            ),
            Text(
              plant.type ?? '',
              textAlign: TextAlign.center, 
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFF747822),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
