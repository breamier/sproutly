import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//services
import 'package:sproutly/services/schedule_service.dart';

//widgets
import 'package:sproutly/widgets/schedule_selector.dart';

//models
import 'package:sproutly/models/water_schedule.dart';
import 'package:sproutly/models/plant.dart';

class WateringScheduleScreen extends StatefulWidget {
  const WateringScheduleScreen({super.key});

  @override
  State<WateringScheduleScreen> createState() => _WateringScheduleScreenState();
}

class _WateringScheduleScreenState extends State<WateringScheduleScreen> {
  String? _selectedPlantId;
  List<DocumentSnapshot> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  bool _isLoadingPlants = false;

  Future<void> _loadPlants() async {
    setState(() => _isLoadingPlants = true);
    try {
      final plants = await ScheduleService().getAllPlants();
      setState(() => _plants = plants);
    } finally {
      setState(() => _isLoadingPlants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleService = Provider.of<ScheduleService>(context);

    if (_isLoadingPlants) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watering Schedule'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // plant selection dropdown
            DropdownButtonFormField<String>(
              value: _selectedPlantId,
              decoration: InputDecoration(
                labelText: 'Select Plant',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _plants
                  .map((doc) {
                    final data = doc.data();
                    if (data == null) return null;
                    final plant = Plant.fromJson(
                      data as Map<String, dynamic>,
                      doc.id,
                    );
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(plant.plantName),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(), // remove nulls
              onChanged: (value) {
                setState(() {
                  _selectedPlantId = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // only show after selecting a plant
            if (_selectedPlantId != null)
              FutureBuilder<WateringSchedule?>(
                future: scheduleService.getSchedule(_selectedPlantId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  return ScheduleSelector(
                    initialSchedule: snapshot.data,
                    plantId: _selectedPlantId!, // Pass the plantId
                    onScheduleSaved: (newSchedule) async {
                      try {
                        // create complete schedule with plantId
                        final completeSchedule = WateringSchedule(
                          selectedWeekdays: newSchedule.selectedWeekdays,
                          wateringTime: newSchedule.wateringTime,
                          plantId: _selectedPlantId!,
                        );

                        await scheduleService.saveSchedule(completeSchedule);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Schedule saved successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving schedule: $e')),
                        );
                      }
                    },
                  );
                },
              ),

            // show message when no plant is selected
            if (_selectedPlantId == null)
              const Center(
                child: Text(
                  'Please select a plant first',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
