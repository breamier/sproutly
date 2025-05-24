import 'package:flutter/material.dart';
import 'plant_issues.dart';

class PlantProfileScreen extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantProfileScreen({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    const Color oliveTitleColor = Color(0xFF747822);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8D5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: oliveTitleColor, width: 1.5),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: oliveTitleColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Plant Profile',
                      style: TextStyle(
                        fontFamily: 'Curvilingus',
                        fontSize: 34,
                        color: oliveTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),

                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: Image.asset(
                        plant['image'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plant['name'] as String,
                      style: TextStyle(
                        fontFamily: 'Curvilingus',
                        fontSize: 40,
                        color: oliveTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plant['type'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: oliveTitleColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // Tip container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: oliveTitleColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/knowledge_icon.png',
                        height: 24,
                        width: 24,
                        color: oliveTitleColor,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. commodo ligula eget dolor',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: oliveTitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCareIcon(
                      iconAsset: 'assets/light_icon.png',
                      label: 'Bright\nlight',
                    ),
                    _buildCareIcon(
                      iconAsset: 'assets/water_icon.png',
                      label: 'Water\nWeekly',
                    ),
                    _buildCareIcon(
                      iconAsset: 'assets/care_icon.png',
                      label: 'High\nCare',
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                _buildActionButton(
                  context: context,
                  label: 'Plant Issues',
                  iconAsset: 'assets/edit_icon.png',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PlantIssuesScreen(plant: plant),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildActionButton(
                  context: context,
                  label: 'Growth Journal',
                  iconAsset: 'assets/journal_icon.png',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Growth Journal tapped')),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareIcon({
    required String iconAsset,
    required String label,
  }) {
    return Column(
      children: [
        Image.asset(
          iconAsset,
          height: 40,
          width: 40,
          color: const Color(0xFF747822),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFF747822),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF747822), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF747822),
              ),
            ),
            Image.asset(
              iconAsset,
              height: 30,
              width: 30,
              color: const Color(0xFF747822),
            ),
          ],
        ),
      ),
    );
  }
}