import 'package:flutter/material.dart';
import 'package:sproutly/main.dart';
import 'package:sproutly/screens/growth_journal/growthjournal_entries_screen.dart';

class GrowthJournalScreen extends StatelessWidget {
  const GrowthJournalScreen({super.key});

  static const Color oliveGreen = Color(0xFF747822);

  static const TextStyle titleFont = TextStyle(
    fontFamily: 'Curvilingus',
    fontWeight: FontWeight.w700,
    fontSize: 40,
    color: oliveGreen,
  );

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: oliveGreen,
  );

  static const TextStyle bodyFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: oliveGreen,
  );

  // Example mock image paths
  final List<String> imagePaths = const [
    'assets/tulips.png',
    'assets/hyacinth.png',
    'assets/tulips.png',
    'assets/hyacinth.png',
    'assets/tulips.png',
    'assets/hyacinth.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF8C8F3E),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Growth Journal",
                  style: TextStyle(
                    fontFamily: 'Curvilingus',
                    fontWeight: FontWeight.w700,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    color: oliveGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text("Notes", style: headingFont),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: oliveGreen),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title", style: headingFont),
                  SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      style: bodyFont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Photos", style: headingFont),
            const SizedBox(height: 12),

            SizedBox(
              height: MediaQuery.of(context).size.width * 0.2 * 1.30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index < imagePaths.length) {
                    return _buildPhoto(context, imagePaths[index]);
                  } else {
                    return _buildAddPhotoBox(context);
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GrowthJournalEntriesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: oliveGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Save  Journal Entry",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(BuildContext context, String path) {
    final screenWidth = MediaQuery.of(context).size.width;
    final photoWidth = screenWidth * 0.2;

    return SizedBox(
      width: photoWidth,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildAddPhotoBox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.2;

    return SizedBox(
      width: boxWidth,
      child: AspectRatio(
        aspectRatio: 3 / 4, // Matches image aspect ratio
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 136, 123, 123)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: Color.fromARGB(255, 136, 123, 123),
                ),
                SizedBox(height: 4),
                Text(
                  "Add new photo",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    color: Color.fromARGB(255, 136, 123, 123),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
