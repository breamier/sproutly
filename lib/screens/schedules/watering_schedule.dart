import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/services/notification_service.dart';

class WateringScheduleScreen extends StatefulWidget {
  final Plant plant;
  const WateringScheduleScreen({super.key, required this.plant});

  @override
  State<WateringScheduleScreen> createState() => _WateringScheduleScreenState();
}

class _WateringScheduleScreenState extends State<WateringScheduleScreen> {
  List<int> _selectedWeekdays = [];
  TimeOfDay? _wateringTime;
  bool _isSaving = false;

  Future<void> _saveWateringReminders() async {
    if (_wateringTime == null || _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select days and time')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final notiService = Provider.of<NotiService>(context, listen: false);

      for (final weekday in _selectedWeekdays) {
        // find the next date for this weekday
        final now = DateTime.now();
        int daysUntil = (weekday - now.weekday) % 7;
        if (daysUntil == 0 &&
            (now.hour > _wateringTime!.hour ||
                (now.hour == _wateringTime!.hour &&
                    now.minute >= _wateringTime!.minute))) {
          daysUntil = 7;
        }
        final nextDate = now.add(Duration(days: daysUntil));
        final reminderDate = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          _wateringTime!.hour,
          _wateringTime!.minute,
        );

        // no duplicate watering reminders for this plant/day/time
        final existing = await db.findReminderByPlantAndType(
          plantId: widget.plant.id,
          reminderType: 'water',
        );
        if (existing != null &&
            existing.reminderDate.weekday == weekday &&
            existing.reminderDate.hour == _wateringTime!.hour &&
            existing.reminderDate.minute == _wateringTime!.minute) {
          continue; // skip duplicate
        }

        final reminder = Reminder(
          id: '',
          plantName: widget.plant.plantName,
          plantId: widget.plant.id,
          reminderDate: reminderDate,
          reminderType: 'water',
          completed: false,
        );
        await db.addReminder(reminder);

        await notiService.scheduleNotification(
          title: 'Water your ${widget.plant.plantName}',
          body: 'It\'s time to water your plant!',
          hour: _wateringTime!.hour,
          minute: _wateringTime!.minute,
          weekday: weekday,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Watering reminders saved and notifications set!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving reminders: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _testWaterNotification() async {
    setState(() => _isSaving = true);
    try {
      final nowPlus30 = DateTime.now().add(const Duration(seconds: 30));
      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.scheduleNotification(
        title: 'Test: Water your ${widget.plant.plantName}',
        body: 'Test: This is a test watering notification!',
        hour: nowPlus30.hour,
        minute: nowPlus30.minute,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification scheduled for 30 seconds from now!'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Watering Schedule for ${widget.plant.plantName}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Watering Days:', style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final weekdayStr = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ][index];
                return FilterChip(
                  label: Text(weekdayStr),
                  selected: _selectedWeekdays.contains(weekday),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWeekdays.add(weekday);
                      } else {
                        _selectedWeekdays.remove(weekday);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Select Time:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _wateringTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => _wateringTime = picked);
                    }
                  },
                  child: Text(
                    _wateringTime == null
                        ? 'Pick Time'
                        : _wateringTime!.format(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B5502),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSaving ? null : _saveWateringReminders,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Watering Schedule'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
