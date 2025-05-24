import 'package:flutter/material.dart';
import 'package:sproutly/auth.dart';
import 'navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sproutly/screens/dev_tools.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final User? user = Auth().currentUser;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> signOut() async {
    try {
      await Auth().signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: () async {
        await signOut();
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
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/sproutly_logo2.png',
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ],
              ),

              _userUid(),
              _signOutButton(),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevToolsPage(userId: userId),
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
                  Text("See all", style: bodyFont.copyWith(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),

              // Reminders
              ReminderCard(
                task: 'Rose needs to be watered',
                time: 'May 1, 2025 11:30 AM',
              ),
              const SizedBox(height: 8),
              ReminderCard(
                task: 'Tulip needs to be watered',
                time: 'May 1, 2025 11:30 AM',
              ),
              const SizedBox(height: 24),

              // Recently added plants
              Text("Recently Added Plants", style: headingFont),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFEF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: PlantThumbnail(
                        name: 'Rose',
                        imagePath: 'assets/rose.png',
                      ),
                    ),
                    Expanded(
                      child: PlantThumbnail(
                        name: 'Hyacinth',
                        imagePath: 'assets/hyacinth.png',
                      ),
                    ),
                  ],
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
        onPressed: () {},
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
  final List<String> tips = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut.',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const TextStyle bodyFont = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentPage < tips.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Icon(Icons.lightbulb_outline, color: Color(0xFF4B5502)),
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
                onPressed: _goToPrevious,
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: _currentPage == 0 ? Colors.grey : Colors.black,
              ),

              // Tip content
              Expanded(
                child: SizedBox(
                  height: 60,
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
                onPressed: _goToNext,
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                color:
                    _currentPage == tips.length - 1
                        ? Colors.grey
                        : Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dot indicator
          Row(
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
        ],
      ),
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
    final imageWidth = screenWidth * 0.2;
    final imageHeight = imageWidth * 1.25;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
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
            fontSize: screenWidth * 0.035,
            color: const Color.fromARGB(255, 114, 120, 49),
          ),
        ),
      ],
    );
  }
}
