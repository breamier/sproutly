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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveWateringReminders() async {
    if (_wateringTime == null || _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select days and time'),
          backgroundColor: Color(0xFF747822),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final notiService = Provider.of<NotiService>(context, listen: false);

      for (final weekday in _selectedWeekdays) {
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

        // generate notificationId after reminder datae
        final notificationId = reminderDate.millisecondsSinceEpoch % 1000000000;

        // no duplicate watering reminders for this plant/day/time
        final existing = await db.findReminderByPlantAndType(
          plantId: widget.plant.id,
          reminderType: 'water',
        );
        if (existing != null &&
            existing.reminderDate.weekday == weekday &&
            existing.reminderDate.hour == _wateringTime!.hour &&
            existing.reminderDate.minute == _wateringTime!.minute) {
          continue;
        }

        final reminder = Reminder(
          id: '',
          plantName: widget.plant.plantName,
          plantId: widget.plant.id,
          reminderDate: reminderDate,
          reminderType: 'water',
          completed: false,
          notificationId: notificationId,
        );
        await db.addReminder(reminder);

        final notificationsEnabled = await DatabaseService()
            .getNotificationsEnabled();
        if (notificationsEnabled) {
          await notiService.scheduleNotification(
            id: notificationId,
            title: 'Water your ${widget.plant.plantName}',
            body: 'It\'s time to water your plant!',
            hour: _wateringTime!.hour,
            minute: _wateringTime!.minute,
            weekday: weekday,
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Watering notification successfully scheduled.'),
          backgroundColor: Color(0xFF747822),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _testWaterNotification() async {
    setState(() => _isSaving = true);
    try {
      final nowPlus30 = DateTime.now().add(const Duration(seconds: 30));
      final notiService = Provider.of<NotiService>(context, listen: false);
      final notificationsEnabled = await DatabaseService()
          .getNotificationsEnabled();
      if (notificationsEnabled) {
        await notiService.scheduleNotification(
          title: 'Water your ${widget.plant.plantName}',
          body: 'This is a test watering notification!',
          hour: nowPlus30.hour,
          minute: nowPlus30.minute,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification scheduled.'),
          backgroundColor: Color(0xFF747822),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildWeekdayChip(int weekday, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedWeekdays.contains(weekday),
      selectedColor: const Color(0xFF747822),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedWeekdays.contains(weekday)
            ? Colors.white
            : const Color(0xFF747822),
      ),
      backgroundColor: const Color(0xFFE8E8D5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF747822), width: 1.5),
      ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 75,
        leadingWidth: 75,
        leading: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8D5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF747822), width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF747822),
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Watering Schedule',
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'Curvilingus',
              fontWeight: FontWeight.bold,
              color: Color(0xFF747822),
            ),
          ),
        ),
        titleSpacing: 8,
        centerTitle: false,
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set watering for "${widget.plant.plantName}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF747822),
                ),
              ),
              const SizedBox(height: 24),

              // Watering Days Selection
              const Text(
                'Select Watering Days:',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF747822),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildWeekdayChip(1, 'Mon'),
                  _buildWeekdayChip(2, 'Tue'),
                  _buildWeekdayChip(3, 'Wed'),
                  _buildWeekdayChip(4, 'Thu'),
                  _buildWeekdayChip(5, 'Fri'),
                  _buildWeekdayChip(6, 'Sat'),
                  _buildWeekdayChip(7, 'Sun'),
                ],
              ),
              const SizedBox(height: 24),

              // Watering Time Selection
              Row(
                children: [
                  const Text(
                    'Select Time:',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF747822),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF8C8F3E),
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _wateringTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF747822),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF747822),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF747822),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _wateringTime = picked);
                        }
                      },
                      child: Text(
                        _wateringTime == null
                            ? 'Pick Time'
                            : _wateringTime!.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF747822),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWateringReminders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF747822),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Watering Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Test Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8E8D5),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: const Color(0xFF747822),
                        width: 2,
                      ),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _testWaterNotification,
                  child: const Text(
                    'Test Notification',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF747822),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
