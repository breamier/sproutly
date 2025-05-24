import 'package:flutter/material.dart';
import 'package:sproutly/main.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  static const TextStyle titleFont = TextStyle(
    fontFamily: 'Curvilingus',
    fontWeight: FontWeight.w700,
    fontSize: 50,
    color: Color(0xFF747822),
  );

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 24,
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

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SproutlyApp(),
                        ),
                      );
                    },
                    child: Icon(
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

            const SizedBox(height: 40),

            // Today's Reminders
            Text("Today's Reminders", style: headingFont),
            const SizedBox(height: 12),
            ReminderCard(task: 'Water the Rose', time: 'May 1, 2025 10:00 AM'),
            const SizedBox(height: 8),
            ReminderCard(
              task: 'Give sunlight to Tulip',
              time: 'May 1, 2025 11:30 AM',
            ),

            const SizedBox(height: 32),

            // Upcoming Reminders
            Text("Upcoming Reminders", style: headingFont),
            const SizedBox(height: 12),
            ReminderCard(
              task:
                  'STEAm THUNDER BY SVT HAPPY 10TH YEAR ANNIVERSARY BABIES KO STEAm THUNDER BY SVT HAPPY 10TH YEAR ANNIVERSARY BABIES KO',
              time: 'May 2, 2025 9:00 AM',
            ),
            const SizedBox(height: 8),

            ReminderCard(
              task: 'Fertilize the Rose',
              time: 'May 3, 2025 1:00 PM',
            ),
            const SizedBox(height: 8),

            ReminderCard(
              task: 'Fertilize the Rose',
              time: 'May 3, 2025 1:00 PM',
            ),
            const SizedBox(height: 8),

            ReminderCard(
              task: 'Fertilize the Rose',
              time: 'May 3, 2025 1:00 PM',
            ),

            const Spacer(),
          ],
        ),
      ),
    );
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
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Text(
                  widget.task,
                  style: RemindersScreen.bodyFont.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF747822),
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              widget.time,
              style: RemindersScreen.bodyFont.copyWith(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
