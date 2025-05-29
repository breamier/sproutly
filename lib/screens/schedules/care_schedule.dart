import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/services/notification_service.dart';

class CareScheduleScreen extends StatefulWidget {
  final Plant plant;
  const CareScheduleScreen({super.key, required this.plant});

  @override
  State<CareScheduleScreen> createState() => _CareScheduleScreenState();
}

class _CareScheduleScreenState extends State<CareScheduleScreen> {
  bool _isSaving = false;
  late List<String> _careLevels = [];

  @override
  void initState() {
    super.initState();
    Provider.of<DatabaseService>(
      context,
      listen: false,
    ).getDropdownOptions('care-level').then((levels) {
      setState(() {
        _careLevels = levels;
      });
    });
  }

  Map<String, dynamic> _getCareReminder(String careLevel) {
    if (_careLevels.isEmpty) {
      return {'type': 'check_health', 'days': 14};
    }
    final lower = careLevel.toLowerCase();
    if (lower == _careLevels[0].toLowerCase()) {
      return {'type': 'check_health', 'days': 30};
    } else if (lower == _careLevels[1].toLowerCase()) {
      return {'type': 'check_health', 'days': 14};
    } else if (lower == _careLevels[2].toLowerCase()) {
      return {'type': 'check_health', 'days': 7};
    } else {
      return {'type': 'check_health', 'days': 14};
    }
  }

  Future<void> _saveCareReminder() async {
    setState(() => _isSaving = true);
    try {
      final reminderInfo = _getCareReminder(widget.plant.careLevel);
      final reminderType = reminderInfo['type'] as String;
      final frequencyDays = reminderInfo['days'] as int;

      final reminderDate = DateTime.now().add(Duration(days: frequencyDays));

      final db = Provider.of<DatabaseService>(context, listen: false);
      final existing = await db.findReminderByPlantAndType(
        plantId: widget.plant.id,
        reminderType: reminderType,
      );
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A care reminder for this plant already exists!'),
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
      debugPrint('Care reminder added to Firestore: ${reminder.toMap()}');

      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.scheduleNotification(
        title: 'Check health of ${widget.plant.plantName}',
        body: 'Time to inspect your plant for issues, pests, or root rot!',
        hour: 10,
        minute: 0,
      );
      debugPrint('Notification scheduled for ${reminder.reminderDate}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Care reminder saved and notification scheduled!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save care reminder: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _testCareNotification() async {
    setState(() => _isSaving = true);
    try {
      final reminderInfo = _getCareReminder(widget.plant.careLevel);
      final nowPlus2 = DateTime.now().add(const Duration(minutes: 1));

      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.scheduleNotification(
        title: 'Check health of ${widget.plant.plantName}',
        body: 'Time to inspect your plant for issues, pests, or root rot!',
        hour: nowPlus2.hour,
        minute: nowPlus2.minute,
      );
      debugPrint('Test care notification scheduled for $nowPlus2');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Test care notification scheduled for 1 minute from now.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule test notification: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderInfo = _getCareReminder(widget.plant.careLevel);
    final frequencyDays = reminderInfo['days'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Reminder'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up a care reminder for "${widget.plant.plantName}"',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Care Level: ${widget.plant.careLevel}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Reminder Type: check_health',
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
                onPressed: _isSaving ? null : _saveCareReminder,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Care Reminder'),
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
                onPressed: _isSaving ? null : _testCareNotification,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Test Care Notification.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
