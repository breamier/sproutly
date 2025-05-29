import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/services/notification_service.dart';

class LightScheduleScreen extends StatefulWidget {
  const LightScheduleScreen({super.key});

  @override
  State<LightScheduleScreen> createState() => _LightScheduleScreenState();
}

class _LightScheduleScreenState extends State<LightScheduleScreen> {
  Plant? _selectedPlant;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Light Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Fetch and show all plants in a dropdown
            StreamBuilder<List<Plant>>(
              stream: db
                  .getUserPlants(), // Implement this to return List<Plant>
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final plants = snapshot.data!;
                return DropdownButton<Plant>(
                  value: _selectedPlant,
                  hint: const Text('Select a plant'),
                  items: plants.map((plant) {
                    return DropdownMenuItem(
                      value: plant,
                      child: Text(plant.plantName),
                    );
                  }).toList(),
                  onChanged: (plant) {
                    setState(() {
                      _selectedPlant = plant;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            if (_selectedPlant != null)
              Expanded(child: LightReminderForm(plant: _selectedPlant!)),
          ],
        ),
      ),
    );
  }
}

// This is your previous form, but as a separate widget:
class LightReminderForm extends StatefulWidget {
  final Plant plant;
  const LightReminderForm({super.key, required this.plant});

  @override
  State<LightReminderForm> createState() => _LightReminderFormState();
}

class _LightReminderFormState extends State<LightReminderForm> {
  // ...copy your previous _LightScheduleScreenState code here...
  bool _isSaving = false;
  late List<String> _sunlightLevels = [];

  @override
  void initState() {
    super.initState();
    // Fetch sunlight levels from Firestore
    Provider.of<DatabaseService>(
      context,
      listen: false,
    ).getDropdownOptions('sunlight-level').then((levels) {
      setState(() {
        _sunlightLevels = levels;
      });
    });
  }

  // Determine reminder type and frequency based on sunlight
  Map<String, dynamic> _getLightReminder(String sunlight) {
    if (_sunlightLevels.isEmpty) {
      // fallback to default if not loaded yet
      return {'type': 'rotate', 'days': 14};
    }
    final lower = sunlight.toLowerCase();
    if (lower == _sunlightLevels[0].toLowerCase()) {
      return {'type': 'check_light', 'days': 21};
    } else if (lower == _sunlightLevels[1].toLowerCase()) {
      return {'type': 'rotate', 'days': 14};
    } else if (lower == _sunlightLevels[2].toLowerCase()) {
      return {'type': 'rotate', 'days': 7};
    } else {
      return {'type': 'rotate', 'days': 14};
    }
  }

  Future<void> _saveLightReminder() async {
    setState(() => _isSaving = true);
    try {
      final reminderInfo = _getLightReminder(widget.plant.sunlight);
      final reminderType = reminderInfo['type'] as String;
      final frequencyDays = reminderInfo['days'] as int;

      final reminderDate = DateTime.now().add(Duration(days: frequencyDays));
      final reminder = Reminder(
        id: '',
        plantId: widget.plant.id,
        reminderDate: reminderDate,
        reminderType: reminderType,
        completed: false,
      );

      // Save to Firestore
      await Provider.of<DatabaseService>(
        context,
        listen: false,
      ).addReminder(reminder);

      // test if it added to firestore
      debugPrint('Reminder added to Firestore: ${reminder.toMap()}');

      // Schedule local notification
      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.scheduleNotification(
        title: reminderType == 'rotate'
            ? 'Rotate your ${widget.plant.plantName}'
            : 'Check light for ${widget.plant.plantName}',
        body: reminderType == 'rotate'
            ? 'It\'s time to rotate your plant for even growth!'
            : 'Check if your plant is getting enough light.',
        hour: 9, // Default to 9 AM
        minute: 0,
        // You can add logic to pick a specific weekday if you want
      );

      // check if notif is added and working
      debugPrint('Notification scheduled for ${reminder.reminderDate}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Light reminder saved and notification scheduled!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save reminder: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderInfo = _getLightReminder(widget.plant.sunlight);
    final reminderType = reminderInfo['type'] as String;
    final frequencyDays = reminderInfo['days'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Schedule'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up a light reminder for "${widget.plant.plantName}"',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Light Level: ${widget.plant.sunlight}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Reminder Type: $reminderType',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Frequency: Every $frequencyDays days',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveLightReminder,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Light Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
