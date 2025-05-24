//imports
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sproutly/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sproutly/widget_tree.dart';

//services
import 'services/database_service.dart';
import 'services/schedule_service.dart';
import 'services/notification_service.dart';

//import 'add_plant.dart';
// import 'package:provider/provider.dart';

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

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<ScheduleService>(create: (_) => ScheduleService()),
        Provider<NotiService>(create: (_) => NotiService()),

        // can add more providers here to share objects and instances
      ],
      child: const SproutlyApp(),
    ),
  );
}

// test if correctly fetching the dropdowns options/values
// Future<void> testPaths() async {
//   final db = DatabaseService();
//   debugPrint('Water levels: ${await db.getDropdownOptions('water-level')}');
//   debugPrint('Sunlight: ${await db.getDropdownOptions('sunlight-level')}');
//   debugPrint('Care levels: ${await db.getDropdownOptions('care-level')}');
//   debugPrint(
//     'Types: ${await db.getDropdownOptions('water-storage-and-adaptation')}',
//   );
// }

class SproutlyApp extends StatelessWidget {
  const SproutlyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      // home: HomeScreen(),
      home: const WidgetTree(),
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

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     const Color buttonColor = Color(0xFF747822);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Sproutly Home Page',
//           style: TextStyle(
//             color: Color(0xFF747822),
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Poppins',
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,

//           children: <Widget>[

// }

// class AppPermissions {
//   static Future<bool> checkAndRequestNotifications() async {
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       final result = await Permission.notification.request();
//       return result.isGranted;
//     }
//     return status.isGranted;
//   }
// }
