import 'package:flutter/material.dart';
import 'package:sproutly/screens/user_plant_library/plant_profile.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sproutly/widgets/navbar.dart';

// for reminders
import '../schedules/light_schedule.dart';
import '../schedules/care_schedule.dart';
import '../schedules/watering_schedule.dart';

class PlantLibraryScreen extends StatefulWidget {
  final int navIndex;
  const PlantLibraryScreen({super.key, this.navIndex = 1});

  @override
  State<PlantLibraryScreen> createState() => _PlantLibraryScreenState();
}

class _PlantLibraryScreenState extends State<PlantLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _showPlantPicker(
    BuildContext context, {
    required String scheduleType,
  }) async {
    final plants = await DatabaseService().getPlants().first;
    final plantList = plants.docs.map((doc) => doc.data() as Plant).toList();

    String getReminderTitle(String type) {
      switch (type) {
        case 'light':
          return 'Sunlight';
        case 'care':
          return 'General Care';
        case 'water':
          return 'Watering';
        default:
          return 'Reminder';
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose a plant to set a ${getReminderTitle(scheduleType)} Reminder',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF747822),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: plantList.map((plant) {
                    return ListTile(
                      leading: plant.img != null && plant.img!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(plant.img!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.local_florist),
                            ),
                      title: Text(plant.plantName),
                      subtitle: Text(plant.type ?? ''),
                      onTap: () {
                        Navigator.pop(ctx);
                        Widget screen;
                        if (scheduleType == 'light' ||
                            scheduleType == 'rotate') {
                          screen = LightScheduleScreen(plant: plant);
                        } else if (scheduleType == 'care') {
                          screen = CareScheduleScreen(plant: plant);
                        } else {
                          screen = WateringScheduleScreen(plant: plant);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screen),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Plants',
                    style: TextStyle(
                      fontFamily: 'Curvilingus',
                      fontSize: 38,
                      color: oliveTitleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

                    // map Firestore docs to Plant objects
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
      floatingActionButton: _buildFloatingActionBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomNavBarPage(selectedIndex: widget.navIndex),
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

  Widget _buildFloatingActionBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set Plant Reminders',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: const Color(0xFF747822),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // light schedule button
              IconButton(
                icon: Image.asset(
                  'assets/light_icon.png',
                  height: 32,
                  width: 32,
                  color: const Color(0xFF747822),
                ),
                tooltip: 'Light Reminder',
                onPressed: () =>
                    _showPlantPicker(context, scheduleType: 'light'),
              ),
              const SizedBox(width: 12),
              // care schedule button
              IconButton(
                icon: Image.asset(
                  'assets/care_icon.png',
                  height: 32,
                  width: 32,
                  color: const Color(0xFF747822),
                ),
                tooltip: 'Care Reminder',
                onPressed: () =>
                    _showPlantPicker(context, scheduleType: 'care'),
              ),
              const SizedBox(width: 12),
              // water schedule button
              IconButton(
                icon: Image.asset(
                  'assets/water_icon.png',
                  height: 32,
                  width: 32,
                  color: const Color(0xFF747822),
                ),
                tooltip: 'Water Reminder',
                onPressed: () =>
                    _showPlantPicker(context, scheduleType: 'water'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
