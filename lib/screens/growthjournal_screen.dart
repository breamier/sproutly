import 'package:flutter/material.dart';

class GrowthJournalScreen extends StatelessWidget {
  const GrowthJournalScreen({super.key});

  static const Color oliveGreen = Color(0xFF747822);

  static const TextStyle titleFont = TextStyle(
    fontFamily: 'Curvilingus',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: oliveGreen,
  );

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: oliveGreen,
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: oliveGreen, width: 2),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: oliveGreen,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Growth Journal", style: titleFont),
              ],
            ),

            const SizedBox(height: 32),

            const Text("Notes", style: headingFont),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: oliveGreen),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title", style: headingFont),
                  SizedBox(height: 8),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    style: bodyFont,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Photos", style: headingFont),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildPhoto("assets/tulips.png"),
                const SizedBox(width: 8),
                _buildPhoto("assets/hyacinth.png"),
                const SizedBox(width: 8),
                _buildAddPhotoBox(),
              ],
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                onPressed: () {},
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

  Widget _buildPhoto(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(path, width: 70, height: 70, fit: BoxFit.cover),
    );
  }

  Widget _buildAddPhotoBox() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20, color: Colors.grey),
            SizedBox(height: 2),
            Text(
              "Add new photo",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
