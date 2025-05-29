import 'package:flutter/material.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  static const TextStyle titleFont = TextStyle(
    fontFamily: 'Curvilingus',
    fontWeight: FontWeight.w700,
    fontSize: 34,
    color: Color(0xFF747822),
  );

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: Color(0xFF747822),
  );

  static const TextStyle bodyFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Color(0xFF747822),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 5.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C8F3E).withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8C8F3E),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8C8F3E),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text("Reminders", style: titleFont),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Reminder>>(
                stream: DatabaseService().getReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reminders found.'));
                  }

                  final reminders = snapshot.data!;
                  final now = DateTime.now();

                  // divide reminders into today's and upcoming
                  final todayReminders = reminders.where((reminder) {
                    final date = reminder.reminderDate;
                    return date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                  }).toList();

                  final upcomingReminders = reminders.where((reminder) {
                    final date = reminder.reminderDate;
                    // return reminders that are not today and not in the past
                    return !(date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day) &&
                        date.isAfter(now);
                  }).toList();

                  // sort both lists by date/time ascending
                  todayReminders.sort(
                    (a, b) => a.reminderDate.compareTo(b.reminderDate),
                  );
                  upcomingReminders.sort(
                    (a, b) => a.reminderDate.compareTo(b.reminderDate),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today's Reminders
                        Text("Today's Reminders", style: headingFont),
                        const SizedBox(height: 12),
                        if (todayReminders.isEmpty)
                          const Text(
                            "No reminders for today.",
                            style: bodyFont,
                          ),
                        ...todayReminders.map(
                          (reminder) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ReminderCard(
                              task: _reminderTaskText(reminder),
                              time: DateFormat(
                                'MMM d, yyyy h:mm a',
                              ).format(reminder.reminderDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Upcoming Reminders
                        Text("Upcoming Reminders", style: headingFont),
                        const SizedBox(height: 12),
                        if (upcomingReminders.isEmpty)
                          const Text("No upcoming reminders.", style: bodyFont),
                        ...upcomingReminders.map(
                          (reminder) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ReminderCard(
                              task: _reminderTaskText(reminder),
                              time: DateFormat(
                                'MMM d, yyyy h:mm a',
                              ).format(reminder.reminderDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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

  // Helper to generate a readable task string
  static String _reminderTaskText(Reminder reminder) {
    switch (reminder.reminderType) {
      case 'water':
        return 'Water the ${reminder.plantName}';
      case 'rotate':
        return 'Rotate your ${reminder.plantName}';
      case 'check_light':
        return 'Check light for ${reminder.plantName}';
      case 'check_health':
        return 'Check health of ${reminder.plantName}';
      default:
        return '${reminder.reminderType} for ${reminder.plantName}';
    }
  }
}

class ReminderCard extends StatefulWidget {
  final String task;
  final String time;

  const ReminderCard({super.key, required this.task, required this.time});

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
              shape: const CircleBorder(),
              activeColor: const Color.fromARGB(255, 85, 91, 16),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task,
                  style: RemindersScreen.bodyFont.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF747822),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.time,
                  style: RemindersScreen.bodyFont.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
