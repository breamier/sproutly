//imports
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sproutly/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sproutly/widget_tree.dart';
// import 'package:firebase_auth_project/auth.dart';

//services
import 'services/database_service.dart';
import 'services/schedule_service.dart';
import 'services/notification_service.dart';

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
Future<void> testPaths() async {
  final db = DatabaseService();
  debugPrint('Water levels: ${await db.getDropdownOptions('water-level')}');
  debugPrint('Sunlight: ${await db.getDropdownOptions('sunlight-level')}');
  debugPrint('Care levels: ${await db.getDropdownOptions('care-level')}');
  debugPrint(
    'Types: ${await db.getDropdownOptions('water-storage-and-adaptation')}',
  );
}

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
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LandingPage(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Landing Page',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => DashboardScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Dashboard',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const GuideBookScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),

//                 child: const Text(
//                   'Guide Book',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const PlantLibraryScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),

//                 child: const Text(
//                   'Plant Library',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const AddNewPlant(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Add Plant',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//             // watering schedule page
//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const WateringScheduleScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: buttonColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Watering Schedule',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await testPaths();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Check console for test results')),
//                   );
//                 },
//                 child: Text('Test Firestore Paths'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
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
