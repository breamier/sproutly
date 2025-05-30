import 'package:flutter/material.dart';
import 'package:sproutly/screens/settings/help_center_screen.dart';
import 'package:sproutly/services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/reminders.dart';

const Color oliveGreen = Color(0xFF747822);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final enabled = await DatabaseService().getNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await DatabaseService().setNotificationsEnabled(value);

    final db = DatabaseService();
    final notiService = NotiService();

    if (!value) {
      // // cancel all notifications, IF DISABLED
      final ids = await db.getAllNotificationIds();
      await notiService.cancelAllRemindersNotifications(ids);
    } else {
      // re-schedule all reminders, IF ENABLED AGAIN
      final reminders = await db.getAllRemindersOnce();
      for (final reminder in reminders.where(
        (r) => !r.reminderType.startsWith('test_'),
      )) {
        // schedule notification
        // generate a new notificationId for each reminder
        final notificationId =
            reminder.reminderDate.millisecondsSinceEpoch % 1000000000;
        await notiService.scheduleNotification(
          id: notificationId,
          title: _reminderTaskText(reminder),
          body: 'Reminder for ${reminder.plantName}',
          hour: reminder.reminderDate.hour,
          minute: reminder.reminderDate.minute,
          // add weekday if needed
        );
        // update notificationId in Firestore
        await db.updateReminder(
          reminder.id,
          reminder.copyWith(notificationId: notificationId),
        );
      }
    }
  }

  // notification title
  String _reminderTaskText(Reminder reminder) {
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
              Container(
                margin: EdgeInsets.only(bottom: verticalPadding * 0.85),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: oliveGreen),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                    horizontal: horizontalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: buttonFontSize,
                          color: oliveGreen,
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: _loading ? null : _toggleNotifications,
                        activeThumbColor: oliveGreen,
                      ),
                    ],
                  ),
                ),
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
