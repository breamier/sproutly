import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/services/notification_service.dart';

class LightScheduleScreen extends StatefulWidget {
  final Plant plant;
  const LightScheduleScreen({super.key, required this.plant});

  @override
  State<LightScheduleScreen> createState() => _LightScheduleScreenState();
}

class _LightScheduleScreenState extends State<LightScheduleScreen> {
  bool _isSaving = false;
  late List<String> _sunlightLevels = [];

  @override
  void initState() {
    super.initState();
    Provider.of<DatabaseService>(
      context,
      listen: false,
    ).getDropdownOptions('sunlight-level').then((levels) {
      setState(() {
        _sunlightLevels = levels;
      });
    });
  }

  Map<String, dynamic> _getLightReminder(String sunlight) {
    if (_sunlightLevels.isEmpty) {
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

      final db = Provider.of<DatabaseService>(context, listen: false);
      final existing = await db.findReminderByPlantAndType(
        plantId: widget.plant.id,
        reminderType: reminderType,
      );
      // if reminder also exist, give message
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A light reminder for this plant already exists!'),
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final reminder = Reminder(
        id: '',
        plantName: widget.plant.plantName,
        plantId: widget.plant.id,
        reminderDate: reminderDate,
        reminderType: reminderType,
        completed: false,
      );

      await db.addReminder(reminder);
      debugPrint('Reminder added to Firestore: ${reminder.toMap()}');

      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.scheduleNotification(
        title: reminderType == 'rotate'
            ? 'Rotate your ${widget.plant.plantName}'
            : 'Check light for ${widget.plant.plantName}',
        body: reminderType == 'rotate'
            ? 'It\'s time to rotate your plant for even growth!'
            : 'Check if your plant is getting enough light.',
        hour: 9,
        minute: 0,
      );
      debugPrint('Notification scheduled for ${reminder.reminderDate}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Light Notification has been scheduled!')),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B5502),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          final reminderInfo = _getLightReminder(
                            widget.plant.sunlight,
                          );
                          final reminderType = reminderInfo['type'] as String;
                          final nowPlus1 = DateTime.now().add(
                            const Duration(minutes: 1),
                          );
                          // schedule a test notification for 1 minute from now
                          final notiService = Provider.of<NotiService>(
                            context,
                            listen: false,
                          );
                          await notiService.scheduleNotification(
                            title: reminderType == 'rotate'
                                ? 'Rotate your ${widget.plant.plantName}'
                                : 'Check light for ${widget.plant.plantName}',
                            body: reminderType == 'rotate'
                                ? 'It\'s time to rotate your plant for even growth!'
                                : 'Check if your plant is getting enough light.',
                            hour: nowPlus1.hour,
                            minute: nowPlus1.minute,
                          );
                          debugPrint(
                            'Test notification scheduled for $nowPlus1',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Test notification scheduled for 1 minute from now.',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to schedule test notification: $e',
                              ),
                            ),
                          );
                        } finally {
                          setState(() => _isSaving = false);
                        }
                      },
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Test Light Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
