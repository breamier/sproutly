//imports
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sproutly/auth.dart';
import 'package:sproutly/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sproutly/screens/dashboard_screen.dart';
import 'package:sproutly/screens/login_register.dart';

//services
import 'services/database_service.dart';
import 'services/notification_service.dart';

// cloudinary purposes
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // initialize database
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Check and request notification permissions
  final hasPermission = await AppPermissions.checkAndRequestNotifications();
  debugPrint('Notification permission granted: $hasPermission');

  // initialize notification
  await NotiService().initNotification();
  // Initialize background notification handler

  // load environment variables from .env file
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<NotiService>(create: (_) => NotiService()),

        // can add more providers here to share objects and instances
      ],
      child: SproutlyApp(),
    ),
  );
}

class SproutlyApp extends StatelessWidget {
  const SproutlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Auth().currentUser;
    return MaterialApp(
      title: 'Sproutly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF747822),
          primary: const Color(0xFF747822),
        ),
        useMaterial3: true,
      ),
      home: user != null ? DashboardScreen() : LoginPage(),
    );
  }
}

class AppPermissions {
  static Future<bool> checkAndRequestNotifications() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    return status.isGranted;
  }
}
