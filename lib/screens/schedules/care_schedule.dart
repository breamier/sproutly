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
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCareReminder(String careLevel) {
    if (_careLevels.isEmpty) {
      return {'type': 'check_health', 'days': 14};
    }
    final lower = careLevel.toLowerCase();
    if (lower == _careLevels[0].toLowerCase()) {
      return {'type': 'Check on your plant\'s health', 'days': 30};
    } else if (lower == _careLevels[1].toLowerCase()) {
      return {'type': 'Check on your plant\'s health', 'days': 14};
    } else if (lower == _careLevels[2].toLowerCase()) {
      return {'type': 'Check on your plant\'s health', 'days': 7};
    } else {
      return {'type': 'Check on your plant\'s health', 'days': 14};
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

      final notificationId = reminderDate.millisecondsSinceEpoch % 1000000000;

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A care reminder for this plant already exists!'),
            backgroundColor: Color(0xFF747822),
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
        notificationId: notificationId,
      );

      await db.addReminder(reminder);

      final notiService = Provider.of<NotiService>(context, listen: false);
      final notificationsEnabled = await DatabaseService()
          .getNotificationsEnabled();
      if (notificationsEnabled) {
        await notiService.scheduleNotification(
          id: notificationId,
          title: 'Check health of ${widget.plant.plantName}',
          body: 'Time to inspect your plant for issues, pests, or root rot!',
          hour: 10,
          minute: 0,
        );
      }
      debugPrint('Notification scheduled for ${reminder.reminderDate}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Care notification successfully scheduled.'),
          backgroundColor: Color(0xFF747822),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save care reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _testCareNotification() async {
    setState(() => _isSaving = true);
    try {
      final nowPlus30 = DateTime.now().add(const Duration(seconds: 30));
      final notificationId = nowPlus30.millisecondsSinceEpoch % 1000000000;
      final db = Provider.of<DatabaseService>(context, listen: false);
      final notiService = Provider.of<NotiService>(context, listen: false);

      // Save a test care reminder
      final testReminder = Reminder(
        id: '',
        plantName: widget.plant.plantName,
        plantId: widget.plant.id,
        reminderDate: nowPlus30,
        reminderType: 'test_care',
        completed: false,
        notificationId: notificationId,
      );
      await db.addReminder(testReminder);

      final notificationsEnabled = await DatabaseService()
          .getNotificationsEnabled();
      if (notificationsEnabled) {
        await notiService.scheduleNotification(
          id: notificationId,
          title: 'Care for ${widget.plant.plantName}',
          body: 'This is a test care notification!',
          hour: nowPlus30.hour,
          minute: nowPlus30.minute,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test care notification scheduled.'),
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

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF8C8F3E), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF747822),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderInfo = _getCareReminder(widget.plant.careLevel);
    final frequencyDays = reminderInfo['days'] as int;

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
            'Care Reminder',
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
                'Set up care for "${widget.plant.plantName}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF747822),
                ),
              ),
              const SizedBox(height: 24),

              _buildInfoCard('Care Level', widget.plant.careLevel),
              _buildInfoCard('Reminder', 'check_health'),
              _buildInfoCard('Frequency', 'Every $frequencyDays days'),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCareReminder,
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
                          'Save Care Reminder',
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
                  onPressed: _isSaving ? null : _testCareNotification,
                  child: Text(
                    'Test Notification',
                    style: const TextStyle(
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
