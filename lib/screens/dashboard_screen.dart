import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutly/auth.dart';
import 'package:sproutly/screens/add_plant/add_plant_camera.dart';
import 'package:sproutly/screens/settings/help_center_screen.dart';
import 'package:sproutly/services/database_service.dart';
import '../widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/user_plant_library/plant_profile.dart';
import 'package:sproutly/screens/reminders_screen.dart';
import 'dart:async';
import 'dart:math' as math;

import '../models/reminders.dart';

class DashboardScreen extends StatelessWidget {
  final int navIndex;
  DashboardScreen({super.key, this.navIndex = 0});

  final User? user = Auth().currentUser;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Helper function for showing today's reminder
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

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Color(0xFF4B5502),
  );

  static const TextStyle bodyFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: Color(0xFF4B5502),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Image.asset(
                'assets/sproutly_logo2.png',
                height: kToolbarHeight + 15,
              ),
            ],
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              // TIPS
              TipsWidget(),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Reminders", style: headingFont),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemindersScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: bodyFont.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<Reminder>>(
                stream: DatabaseService().getReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reminders for today.",
                        style: DashboardScreen.bodyFont,
                      ),
                    );
                  }

                  final reminders = snapshot.data!;
                  final now = DateTime.now();

                  // filter for today's reminders
                  final todayReminders =
                      reminders.where((reminder) {
                        final date = reminder.reminderDate;
                        return date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;
                      }).toList();

                  todayReminders.sort((a, b) {
                    if (a.completed == b.completed) {
                      return a.reminderDate.compareTo(b.reminderDate);
                    }
                    return a.completed ? 1 : -1;
                  });

                  if (todayReminders.isEmpty) {
                    return const Text(
                      "No reminders for today.",
                      style: DashboardScreen.bodyFont,
                    );
                  }

                  // show up to 3 reminders
                  return Column(
                    children: [
                      ...todayReminders
                          .take(3)
                          .map(
                            (reminder) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ReminderCard(
                                reminder: reminder,
                                task: _reminderTaskText(reminder),
                                time: DateFormat(
                                  'MMM d, yyyy h:mm a',
                                ).format(reminder.reminderDate),
                                onChanged: (value) async {
                                  final updated = reminder.copyWith(
                                    completed: value ?? false,
                                  );
                                  await DatabaseService().updateReminder(
                                    reminder.id,
                                    updated,
                                  );
                                },
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Recently added plants
              Text("Recently Added Plants", style: headingFont),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),

                child: StreamBuilder(
                  stream: DatabaseService().getRecentPlants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Add some plants!', style: bodyFont),
                            Transform.rotate(
                              angle: math.pi / 8,
                              child: Image.asset(
                                'assets/arrow.png',
                                height: 150,
                                width: 150,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final plants =
                        snapshot.data!.docs.map((doc) => doc.data()).toList();
                    return RawScrollbar(
                      thumbColor: const Color(0xFF6C7511),
                      radius: const Radius.circular(8),
                      thickness: 8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              plants.map((plant) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12,
                                    bottom: 12,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      final userId =
                                          FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.uid ??
                                          '';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PlantProfileScreen(
                                                userId: userId,
                                                plantId: plant.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: PlantThumbnail(
                                      name: plant.plantName,
                                      imagePath:
                                          plant.img ?? 'assets/placeholder.png',
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Add plant button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C7511),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPlantCamera(addPlant: true),
            ),
          );
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // navbar
      bottomNavigationBar: CustomNavBarPage(selectedIndex: navIndex),
    );
  }
}

class TipsWidget extends StatefulWidget {
  const TipsWidget({super.key});

  @override
  State<TipsWidget> createState() => _TipsWidgetState();
}

class _TipsWidgetState extends State<TipsWidget> {
  late Future<List<String>> tips;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const TextStyle bodyFont = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    tips = DatabaseService().getAllCareTips();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(List<String> tips) {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        int nextPage = (_currentPage + 1) % tips.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll(List<String> tips) {
    _autoScrollTimer?.cancel();
    _startAutoScroll(tips);
  }

  void _goToPrevious(List<String> tips) {
    _stopAutoScroll();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to last page if at first page
      _pageController.animateToPage(
        tips.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Resume auto-scroll after 3 seconds of user interaction
    Timer(const Duration(seconds: 3), () {
      if (mounted) _resumeAutoScroll(tips);
    });
  }

  void _goToNext(List<String> tips) {
    _stopAutoScroll();
    if (_currentPage < tips.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to first page if at last page
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    Timer(const Duration(seconds: 3), () {
      if (mounted) _resumeAutoScroll(tips);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: tips,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tips available.'));
        }
        final tips = snapshot.data!;
        // Start auto-scroll after tips are loaded
        if (_autoScrollTimer == null) {
          _startAutoScroll(tips);
        }
        return GestureDetector(
          onTap: () {
            // Pause auto-scroll when user taps the widget
            _stopAutoScroll();
            Timer(const Duration(seconds: 3), () {
              if (mounted) _resumeAutoScroll(tips);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EFEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header with icon
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF4B5502),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Plant Care Tips',
                        style: DashboardScreen.headingFont,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Slider with arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left arrow
                    IconButton(
                      onPressed: () => _goToPrevious(tips),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      color: Colors.black,
                    ),

                    // Tip content
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: tips.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Center(
                              child: Text(
                                tips[index],
                                style: bodyFont,
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Right arrow
                    IconButton(
                      onPressed: () => _goToNext(tips),
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      color: Colors.black,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Dot indicator
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(tips.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? const Color(0xFF4B5502)
                                  : Colors.grey[400],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final ValueChanged<bool?>? onChanged;
  final String task;
  final String time;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onChanged,
    required this.task,
    required this.time,
  });

  static const TextStyle bodyFont = DashboardScreen.bodyFont;

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              value: widget.reminder.completed,
              onChanged: widget.onChanged,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.task,
                        style: ReminderCard.bodyFont.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 114, 120, 49),
                        ),
                      ),
                    ),
                    Text(
                      widget.time,
                      style: ReminderCard.bodyFont.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlantThumbnail extends StatelessWidget {
  final String name;
  final String imagePath;

  const PlantThumbnail({
    super.key,
    required this.name,
    required this.imagePath,
  });

  static const TextStyle headingFont = DashboardScreen.headingFont;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.4;
    final imageHeight = imageWidth * 1.25;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagePath,
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: bodyFont.copyWith(
            fontSize: screenWidth * 0.05,
            color: const Color.fromARGB(255, 114, 120, 49),
          ),
        ),
      ],
    );
  }
}
