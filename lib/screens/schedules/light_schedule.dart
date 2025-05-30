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
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

      // generate notificationId
      final notificationId = reminderDate.millisecondsSinceEpoch % 1000000000;

      // if reminder also exist, give message
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A light reminder for this plant already exists!'),
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
          title: reminderType == 'rotate'
              ? 'Rotate your ${widget.plant.plantName}'
              : 'Check light for ${widget.plant.plantName}',
          body: reminderType == 'rotate'
              ? 'It\'s time to rotate your plant for even growth!'
              : 'Check if your plant is getting enough light.',
          hour: 9,
          minute: 0,
        );
      }
      debugPrint('Notification scheduled for ${reminder.reminderDate}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification scheduled for 1 minute from now.'),
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

  Future<void> _testLightNotification() async {
    setState(() => _isSaving = true);
    try {
      final nowPlus1 = DateTime.now().add(const Duration(minutes: 1));
      final notificationId = nowPlus1.millisecondsSinceEpoch % 1000000000;
      final db = Provider.of<DatabaseService>(context, listen: false);
      final notiService = Provider.of<NotiService>(context, listen: false);

      // Save a test light reminder
      final testReminder = Reminder(
        id: '',
        plantName: widget.plant.plantName,
        plantId: widget.plant.id,
        reminderDate: nowPlus1,
        reminderType: 'test_light',
        completed: false,
        notificationId: notificationId,
      );
      await db.addReminder(testReminder);

      final notificationsEnabled = await DatabaseService()
          .getNotificationsEnabled();
      if (notificationsEnabled) {
        await notiService.scheduleNotification(
          id: notificationId,
          title: 'Test: Light for ${widget.plant.plantName}',
          body: 'Test: This is a test light notification!',
          hour: nowPlus1.hour,
          minute: nowPlus1.minute,
        );
      }
      debugPrint('Test notification scheduled for $nowPlus1');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Test light notification scheduled for 1 minute from now.',
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
    final reminderInfo = _getLightReminder(widget.plant.sunlight);
    final reminderType = reminderInfo['type'] as String;
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
            'Light Schedule',
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
                'Set up light for "${widget.plant.plantName}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF747822),
                ),
              ),
              const SizedBox(height: 24),

              _buildInfoCard('Light Level', widget.plant.sunlight),
              _buildInfoCard('Reminder Type', reminderType),
              _buildInfoCard('Frequency', 'Every $frequencyDays days'),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLightReminder,
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
                          'Save Light Reminder',
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
                  onPressed: _isSaving ? null : _testLightNotification,
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
