import 'package:flutter/material.dart';
import 'package:sproutly/main.dart';

const Color oliveGreen = Color(0xFF747822);

const TextStyle titleFont = TextStyle(
  fontFamily: 'Curvilingus',
  fontWeight: FontWeight.w700,
  fontSize: 38,
  color: oliveGreen,
);

const TextStyle headingFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: oliveGreen,
);

const TextStyle bodyFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
  fontSize: 12,
  color: oliveGreen,
);

class GrowthJournalEntriesScreen extends StatelessWidget {
  const GrowthJournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: oliveGreen,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8C8F3E),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Growth Journal',
                    style: TextStyle(
                      fontFamily: 'Curvilingus',
                      fontWeight: FontWeight.w700,
                      fontSize: (MediaQuery.of(context).size.width * 0.08)
                          .clamp(24.0, 38.0),
                      color: const Color(0xFF747822),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Text('My Entries', style: headingFont.copyWith(fontSize: 24)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildJournalEntry(),
                    const SizedBox(height: 16),
                    _buildJournalEntry(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntry() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F4F4),
        border: Border.all(color: oliveGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE LAYOUT
          Row(
            children: [
              // Left large image
              Expanded(
                flex: 2,
                child: _buildAssetImage('assets/tulips.png', height: 150),
              ),
              const SizedBox(width: 8),
              // Middle large image
              Expanded(
                flex: 2,
                child: _buildAssetImage('assets/hibiscus.png', height: 150),
              ),
              const SizedBox(width: 8),
              // Right stacked images
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildAssetImage('assets/hyacinth.png', height: 70),
                    const SizedBox(height: 8),
                    _buildStackedImage('assets/rose.png', height: 70),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Tulip Growth Stages', style: headingFont),
          const SizedBox(height: 4),
          Text(
            'Documenting the journey from bud to bloom. Potted tulips showing healthy development.',
            style: bodyFont,
          ),
          const SizedBox(height: 8),
          const Text(
            'May 1, 2025, 11:30 AM',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage(String path, {double height = 100}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildStackedImage(String path, {double height = 100}) {
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
          ),
        ),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            // borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '+2',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
