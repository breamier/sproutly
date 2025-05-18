//imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//services
import '../services/notification_service.dart';

//models
import 'package:sproutly/models/water_schedule.dart';

class ScheduleSelector extends StatefulWidget {
  final WateringSchedule? initialSchedule;
  final Function(WateringSchedule) onScheduleSaved;
  final String plantId;

  const ScheduleSelector({
    super.key,
    this.initialSchedule,
    required this.onScheduleSaved,
    required this.plantId,
  });

  @override
  _ScheduleSelectorState createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  List<int> selectedDays = [];
  TimeOfDay? selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // already has schedule
    if (widget.initialSchedule != null) {
      selectedDays = List.from(widget.initialSchedule!.selectedWeekdays);
      selectedTime = widget.initialSchedule!.wateringTime;
    } else {
      // init default values
      selectedDays = [];
      selectedTime = TimeOfDay.now();
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      selectedDays.sort();
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    // current time in local timezone
    final now = TimeOfDay.now();

    // set initial time to either the selected time or current time
    final initialTime = selectedTime ?? now;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF747822),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: MediaQuery.of(
                context,
              ).alwaysUse24HourFormat,
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Watering Days',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF747822),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = index + 1;
            final isSelected = selectedDays.contains(day);
            final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

            return GestureDetector(
              onTap: () => _toggleDay(day),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF747822)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(
          'Select Watering Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF747822),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          title: Text(
            selectedTime?.format(context) ?? 'Select Time',
            style: const TextStyle(fontSize: 16),
          ),
          trailing: const Icon(Icons.access_time, color: Color(0xFF747822)),
          onTap: () => _selectTime(context),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF747822),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSaving ? null : _saveSchedule,
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _testNotification(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Test Notification',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    if (selectedDays.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day and a time'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newSchedule = WateringSchedule(
        selectedWeekdays: selectedDays,
        wateringTime: selectedTime!,
        plantId: widget.plantId,
      );

      await widget.onScheduleSaved(newSchedule);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save schedule: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _testNotification(BuildContext context) async {
    try {
      final notiService = Provider.of<NotiService>(context, listen: false);
      await notiService.showNotification(
        title: 'Test Watering Reminder',
        body: 'This is a test notification for your watering schedule',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test notification sent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send test notification: $e')),
      );
    }
  }
}