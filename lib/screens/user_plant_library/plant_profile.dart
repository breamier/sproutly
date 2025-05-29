import 'package:flutter/material.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/screens/growth_journal/growthjournal_entries_screen.dart';
import 'package:sproutly/services/database_service.dart';
import 'plant_issues.dart';

//cloudinary delete function
import 'edit_plant_form.dart';

class PlantProfileScreen extends StatefulWidget {
  final String userId;
  final String plantId;

  const PlantProfileScreen({
    super.key,
    required this.userId,
    required this.plantId,
  });

  @override
  State<PlantProfileScreen> createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  // for plant image ideth
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    const Color oliveTitleColor = Color(0xFF747822);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8D5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: oliveTitleColor, width: 1.5),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: oliveTitleColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Text(
                      'Plant Profile',
                      style: TextStyle(
                        fontFamily: 'Curvilingus',
                        fontSize: 34,
                        color: oliveTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  // edit icon
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      color: oliveTitleColor,
                      size: 30,
                    ),
                    onPressed: () async {
                      // Get the current plant from your FutureBuilder
                      final plant = await DatabaseService().getPlantProfileById(
                        widget.userId,
                        widget.plantId,
                      );

                      if (plant == null) return;
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditPlantForm(
                                userId: widget.userId,
                                plant: plant,
                              ),
                        ),
                      );
                      if (updated == true)
                        setState(() {}); // Refresh after editing
                    },
                  ),
                  const Spacer(),
                  // edit icon
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      color: oliveTitleColor,
                      size: 30,
                    ),
                    onPressed: () async {
                      // Get the current plant from your FutureBuilder
                      final plant = await DatabaseService().getPlantProfileById(
                        widget.userId,
                        widget.plantId,
                      );

                      if (plant == null) return;
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditPlantForm(
                                userId: widget.userId,
                                plant: plant,
                              ),
                        ),
                      );
                      if (updated == true)
                        setState(() {}); // Refresh after editing
                    },
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: FutureBuilder<Plant?>(
                future: DatabaseService().getPlantProfileById(
                  widget.userId,
                  widget.plantId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Plant not found'));
                  }
                  final plant = snapshot.data!;
                  final _imageUrl = plant.img;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),

                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 230,
                                height: 230,
                                child:
                                    (_imageUrl ?? '').isNotEmpty
                                        ? Image.network(
                                          _imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 60,
                                                      color: Color(0xFF747822),
                                                    ),
                                                  ),
                                        )
                                        : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.local_florist,
                                            size: 60,
                                            color: oliveTitleColor,
                                          ),
                                        ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.plantName,
                                style: TextStyle(
                                  fontFamily: 'Curvilingus',
                                  fontSize: 40,
                                  color: oliveTitleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  plant.type ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    color: oliveTitleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Tip container
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: oliveTitleColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/knowledge_icon.png',
                                  height: 24,
                                  width: 24,
                                  color: oliveTitleColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. commodo ligula eget dolor',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: oliveTitleColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildCareIcon(
                                  iconAsset: 'assets/light_icon.png',
                                  label: plant.sunlight,
                                ),
                              ),
                              Flexible(
                                child: _buildCareIcon(
                                  iconAsset: 'assets/water_icon.png',
                                  label: plant.water,
                                ),
                              ),
                              Flexible(
                                child: _buildCareIcon(
                                  iconAsset: 'assets/care_icon.png',
                                  label: plant.careLevel,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          _buildActionButton(
                            context: context,
                            label: 'Plant Issues',
                            iconAsset: 'assets/edit_icon.png',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) =>
                                        PlantIssuesScreen(plantId: plant.id),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          _buildActionButton(
                            context: context,
                            label: 'Growth Journal',
                            iconAsset: 'assets/journal_icon.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => GrowthJournalEntriesScreen(
                                        plantId: plant.id,
                                      ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareIcon({required String iconAsset, required String label}) {
    return Column(
      children: [
        Image.asset(
          iconAsset,
          height: 40,
          width: 40,
          color: const Color(0xFF747822),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF747822),
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF747822), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF747822),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              iconAsset,
              height: 30,
              width: 30,
              color: const Color(0xFF747822),
            ),
          ],
        ),
      ),
    );
  }
}
