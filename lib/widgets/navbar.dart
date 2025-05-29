import 'package:flutter/material.dart';
import '../screens/user_plant_library/plant_library.dart';
import '../screens/guide_book/guide_book.dart';
import '../screens/dashboard_screen.dart';

class CustomNavBarPage extends StatefulWidget {
  const CustomNavBarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomNavBarPageState createState() => _CustomNavBarPageState();
}

class _CustomNavBarPageState extends State<CustomNavBarPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to corresponding screens
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlantLibraryScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GuideBookScreen()),
        );
        break;
      case 3:
        // Settings - just clickable for now, no navigation
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6C7511)),
        borderRadius: BorderRadius.circular(30),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.local_florist, 1),
          _buildNavItem(Icons.menu_book, 2),
          _buildNavItem(Icons.settings, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFDCE093),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(icon, color: const Color(0xFF6C7511)),
      ),
    );
  }
}