import 'package:flutter/material.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/models/reminders.dart';
import 'package:intl/intl.dart';
import 'package:sproutly/screens/schedules/light_schedule.dart';
import 'package:sproutly/screens/schedules/care_schedule.dart';
import 'package:sproutly/screens/schedules/watering_schedule.dart';
import 'package:sproutly/models/plant.dart';

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

  Future<void> _showPlantPicker(
    BuildContext context, {
    required String scheduleType,
  }) async {
    final plants = await DatabaseService().getPlants().first;
    final plantList = plants.docs.map((doc) => doc.data() as Plant).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F4F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select a Plant',
                style: const TextStyle(
                  fontFamily: 'Curvilingus',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF747822),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: plantList.isEmpty
                    ? const Center(
                        child: Text(
                          'No plants found.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: Color(0xFF747822),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: plantList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final plant = plantList[index];
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.pop(ctx);
                                Widget screen;
                                if (scheduleType == 'light' ||
                                    scheduleType == 'rotate') {
                                  screen = LightScheduleScreen(plant: plant);
                                } else if (scheduleType == 'care') {
                                  screen = CareScheduleScreen(plant: plant);
                                } else {
                                  screen = WateringScheduleScreen(plant: plant);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => screen,
                                  ),
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                leading:
                                    plant.img != null && plant.img!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          plant.img!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Color(0xFFE8E8D5),
                                        child: Icon(
                                          Icons.local_florist,
                                          color: Color(0xFF747822),
                                        ),
                                      ),
                                title: Text(
                                  plant.plantName,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF747822),
                                  ),
                                ),
                                subtitle: Text(
                                  plant.type ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Color(0xFF747822),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF747822),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                      color: const Color(0xFF8C8F3E).withValues(alpha: 0.25),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'light_reminder',
              backgroundColor: const Color(0xFF747822),
              onPressed: () => _showPlantPicker(context, scheduleType: 'light'),
              child: Image.asset(
                'assets/light_icon.png',
                height: 28,
                width: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'care_reminder',
              backgroundColor: const Color(0xFF747822),
              onPressed: () => _showPlantPicker(context, scheduleType: 'care'),
              child: Image.asset(
                'assets/care_icon.png',
                height: 28,
                width: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'water_reminder',
              backgroundColor: const Color(0xFF747822),
              onPressed: () => _showPlantPicker(context, scheduleType: 'water'),
              child: Image.asset(
                'assets/water_icon.png',
                height: 28,
                width: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
