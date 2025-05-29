import 'package:flutter/material.dart';

const Color oliveGreen = Color(0xFF747822);

double scaleFontSize(BuildContext context, double fontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  return fontSize * (screenWidth / 375);
}

const TextStyle titleFont = TextStyle(
  fontFamily: 'Curvilingus',
  fontWeight: FontWeight.w700,
  fontSize: 32,
  color: oliveGreen,
);

const TextStyle headingFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: oliveGreen,
);

const TextStyle bodyFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
  fontSize: 12,
  color: oliveGreen,
);

final List<Map<String, String>> faqList = [
  {
    'question': 'What is Sproutly?',
    'answer':
        'Sproutly is a mobile app that helps users care for and track the growth of their plants. It offers features like care reminders, plant journals, and a guidebook for plant care based on type, water, light needs, and difficulty level.',
  },
  {
    'question': 'Who is Sproutly for?',
    'answer':
        'Sproutly is designed for houseplant owners, plant enthusiasts, gardeners (beginners to experienced), and anyone who wants to organize and improve their plant care routine.',
  },
  {
    'question': 'How do I add a new plant to Sproutly?',
    'answer':
        'Tap the Add Plant floating action button from the Your Plants page. Fill out the plant’s name, type, watering routine, sunlight requirement, and care level. You can also upload a photo and set reminders.',
  },
  {
    'question': 'Can I set reminders to water or fertilize my plants?',
    'answer':
        'Yes! Sproutly includes a built-in Plant Reminder with Calendar feature. You can plan and manage watering/fertilizing schedules and receive notifications.',
  },
  {
    'question': 'How can I track the growth of my plant?',
    'answer':
        'Use the Growth Journal in the plant’s profile. Add text entries and upload photos to document growth milestones over time.',
  },
  {
    'question': 'What if my plant gets sick?',
    'answer':
        'Go to the Plant Issues tab within the plant’s profile to log symptoms. Sproutly will suggest remedies based on common issues using its built-in guidebook.',
  },
  {
    'question': 'What is the Guidebook feature?',
    'answer':
        'The Guidebook is a library of plant profiles with care tips based on light, water, and difficulty. It includes example species and search/filter options.',
  },
  {
    'question': 'Does Sproutly provide personalized care tips?',
    'answer':
        'Yes. Based on plant type and user location (e.g., climate), Sproutly offers personalized care tips such as temperature sensitivity and seasonal advice.',
  },
  {
    'question': 'Can I search or filter my plants?',
    'answer':
        'Yes! Both the Dashboard and Guidebook pages allow searching and filtering by light needs, water schedule, or care difficulty.',
  },
  {
    'question': 'Can I edit or delete plant entries?',
    'answer':
        'Yes. Open the plant’s profile and tap the edit icon or options menu to make changes or remove the plant.',
  },
  {
    'question': 'Will I get reminders even when the app is closed?',
    'answer':
        'Yes, Sproutly sends care reminders through notifications even when the app is closed or in the background.',
  },
  {
    'question': 'Is there a way to mark plant issues as resolved?',
    'answer':
        'Yes. In the Plant Issues tab, you can mark resolved issues to keep your plant\'s health log organized.',
  },
];

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, String>> _filteredFaqList;

  @override
  void initState() {
    super.initState();
    _filteredFaqList = faqList;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqList = faqList.where((faq) {
        final question = faq['question']!.toLowerCase();
        final answer = faq['answer']!.toLowerCase();
        return question.contains(query) || answer.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
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
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8C8F3E),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Help Center',
                    style: titleFont.copyWith(
                      fontSize: scaleFontSize(context, 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Got questions about using Sproutly?\nYou're in the right place! Check out these\nquick answers to help you care for\nyour plants with ease.",
                  style: bodyFont.copyWith(
                    height: 1.5,
                    fontSize: scaleFontSize(context, 15),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: oliveGreen.withOpacity(0.25),
                  border: Border.all(color: oliveGreen),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                        ),
                        style: bodyFont.copyWith(
                          fontSize: scaleFontSize(context, 12),
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: oliveGreen),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'FAQS',
                style: headingFont.copyWith(
                  fontSize: scaleFontSize(context, 16),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredFaqList.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final item = _filteredFaqList[index];
                    return ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        item['question']!,
                        style: bodyFont.copyWith(
                          fontSize: scaleFontSize(context, 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      iconColor: oliveGreen,
                      collapsedIconColor: oliveGreen,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            bottom: 12,
                          ),
                          child: Text(
                            item['answer']!,
                            style: bodyFont.copyWith(
                              fontSize: scaleFontSize(context, 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
