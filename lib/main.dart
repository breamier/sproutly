import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sproutly/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/models/plant.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            _ListPlants(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Plant plant = Plant(
            plantName: "New Plant",
            addedOn: Timestamp.now(),
            type: "Type of Plant",
          );
          _databaseService.addPlant(plant);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _ListPlants() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
        stream: _databaseService.getPlants(),
        builder: (context, snapshot) {
          List plants = snapshot.data?.docs ?? [];
          if (plants.isEmpty) {
            return const Center(child: Text("Add a plant!"));
          }
          print(plants);

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              // Instance of Plant (can access stuff through plant.plantName)
              Plant plant = plants[index].data();
              // Get plan id
              String plantId = plants[index].id;
              print(plantId);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: ListTile(
                  tileColor: Colors.amberAccent,
                  title: Text(plant.plantName),
                  subtitle: Text(
                    DateFormat(
                      "dd-MM-YYYY h:mm a",
                    ).format(plant.addedOn.toDate()),
                  ),
                  onTap: () {
                    _databaseService.deletePlant(plantId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
