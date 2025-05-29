import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutly/auth.dart';
import 'package:sproutly/screens/add_plant/add_plant_camera.dart';
import 'package:sproutly/services/database_service.dart';
import '../widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sproutly/screens/dev_tools.dart';
import 'package:sproutly/screens/login_register.dart';
import 'package:sproutly/screens/add_plant/add_plant_camera.dart';
import 'package:sproutly/screens/reminders_screen.dart';
import 'dart:async';

import '../models/reminders.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

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

  Future<void> signOut(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  Widget _userNameWidget() {
    return FutureBuilder<String?>(
      future: DatabaseService().getCurrentUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading username...');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Username not found');
        }
        return Text('Username: ${snapshot.data!}');
      },
    );
  }

  Widget _userUid() {
    return Column(
      children: [
        Text(user?.uid ?? 'User uid'),
        Text(user?.email ?? 'User email'),
      ],
    );
  }

  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await signOut(context);
      },
      child: const Text('Sign Out'),
    );
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
    color: Colors.black87,
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
              _userNameWidget(),
              _userUid(),
              _signOutButton(context),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: userId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DevToolsPage(userId: userId!),
                          ),
                        );
                      },
                child: const Text('Dev Tools'),
              ),

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
                      style: bodyFont.copyWith(color: Colors.grey),
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
                    return const Text(
                      "No reminders for today.",
                      style: DashboardScreen.bodyFont,
                    );
                  }

                  final reminders = snapshot.data!;
                  final now = DateTime.now();

                  // filter for today's reminders
                  final todayReminders = reminders.where((reminder) {
                    final date = reminder.reminderDate;
                    return date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                  }).toList();

                  todayReminders.sort(
                    (a, b) => a.reminderDate.compareTo(b.reminderDate),
                  );

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
                                task: _reminderTaskText(reminder),
                                time: DateFormat(
                                  'MMM d, yyyy h:mm a',
                                ).format(reminder.reminderDate),
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
                      return const Center(child: Text('No plants added yet.'));
                    }

                    final plants = snapshot.data!.docs
                        .map((doc) => doc.data())
                        .toList();
                    return RawScrollbar(
                      thumbVisibility: true,
                      thumbColor: const Color(0xFF6C7511),
                      radius: const Radius.circular(8),
                      thickness: 8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: plants.map((plant) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                bottom: 12,
                              ),
                              child: PlantThumbnail(
                                name: plant.plantName,
                                imagePath:
                                    plant.img ?? 'assets/placeholder.png',
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
      bottomNavigationBar: CustomNavBarPage(),
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
                      Text('Tips', style: DashboardScreen.headingFont),
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
                          color: _currentPage == index
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

class ReminderCard extends StatelessWidget {
  final String task;
  final String time;

  const ReminderCard({super.key, required this.task, required this.time});

  static const TextStyle bodyFont = DashboardScreen.bodyFont;

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
          const Icon(
            Icons.radio_button_unchecked,
            color: Color.fromARGB(255, 85, 91, 16),
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
                        task,
                        style: bodyFont.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 114, 120, 49),
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: bodyFont.copyWith(
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
          style: headingFont.copyWith(
            fontSize: screenWidth * 0.05,
            color: const Color.fromARGB(255, 114, 120, 49),
          ),
        ),
      ],
    );
  }
}
