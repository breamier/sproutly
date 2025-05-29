import 'package:flutter/material.dart';
import 'package:sproutly/screens/settings/help_center_screen.dart';

const Color oliveGreen = Color(0xFF747822);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSettingsButton(
    BuildContext context,
    String text,
    IconData icon, {
    Color bgColor = Colors.white,
    Color textColor = oliveGreen,
    required double fontSize,
    required double iconSize,
    required double verticalPadding,
    required double horizontalPadding,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: verticalPadding * 0.85),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: oliveGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          elevation: 4,
        ),
        onPressed: () {
          if (text == 'Help Center') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
            ),
            Icon(icon, size: iconSize, color: textColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double buttonFontSize = screenWidth * 0.045;
    double iconSize = screenWidth * 0.05;
    double verticalPadding = screenWidth * 0.035;
    double horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Curvilingus',
            fontWeight: FontWeight.w700,
            fontSize: 50,
            color: oliveGreen,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.015),
              Center(
                child: Icon(
                  Icons.eco,
                  color: oliveGreen,
                  size: screenWidth * 0.08,
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Center(
                child: Text(
                  'LeyHong',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.07,
                    color: oliveGreen,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'leyhong@hybe.svt',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.045,
                      color: oliveGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              const Divider(color: oliveGreen),
              SizedBox(height: screenWidth * 0.025),
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: screenWidth * 0.06,
                  color: oliveGreen,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),

              _buildSettingsButton(
                context,
                'Help Center',
                Icons.help_outline,
                fontSize: buttonFontSize,
                iconSize: iconSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildSettingsButton(
                context,
                'Turn off Notifications',
                Icons.notifications_off,
                fontSize: buttonFontSize,
                iconSize: iconSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildSettingsButton(
                context,
                'Clear Database',
                Icons.cancel,
                bgColor: const Color(0xFFBFBFB4),
                textColor: Colors.white,
                fontSize: buttonFontSize,
                iconSize: iconSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
              _buildSettingsButton(
                context,
                'Sign Out',
                Icons.logout,
                bgColor: const Color(0xFFE3B4B4),
                textColor: Colors.white,
                fontSize: buttonFontSize,
                iconSize: iconSize,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
