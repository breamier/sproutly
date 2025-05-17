import 'package:flutter/material.dart';
import 'package:sproutly/services/database_service.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});
  //final String title;

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text("Add Plant"),
      ),
      // body: Center(
      //   child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: <Widget>[
      //           const Text('You have pushed the button this many times:'),
      //           _ListPlants(),
      //         ],
      //       ),
      //     ),
      //     floatingActionButton: FloatingActionButton(
      //       onPressed: () {
      //         Plant plant = Plant(
      //           plantName: "New Plant",
      //           addedOn: Timestamp.now(),
      //           type: "Type of Plant",
      //         );
      //         _databaseService.addPlant(plant);
      //       },
      //       tooltip: 'Increment',
      //       child: const Icon(Icons.add),
      //     ),
      //   );
      // }

      // Widget _ListPlants() {
      //   return SizedBox(
      //     height: MediaQuery.sizeOf(context).height * 0.80,
      //     width: MediaQuery.sizeOf(context).width,
      //     child: StreamBuilder(
      //       stream: _databaseService.getPlants(),
      //       builder: (context, snapshot) {
      //         List plants = snapshot.data?.docs ?? [];
      //         if (plants.isEmpty) {
      //           return const Center(child: Text("Add a plant!"));
      //         }
      //         print(plants);

      //         return ListView.builder(
      //           itemCount: plants.length,
      //           itemBuilder: (context, index) {
      //             // Instance of Plant (can access stuff through plant.plantName)
      //             Plant plant = plants[index].data();
      //             // Get plan id
      //             String plantId = plants[index].id;
      //             print(plantId);
      //             return Padding(
      //               padding: const EdgeInsets.symmetric(
      //                 vertical: 10,
      //                 horizontal: 10,
      //               ),
      //               child: ListTile(
      //                 tileColor: Colors.amberAccent,
      //                 title: Text(plant.plantName),
      //                 subtitle: Text(
      //                   DateFormat(
      //                     "dd-MM-YYYY h:mm a",
      //                   ).format(plant.addedOn.toDate()),
      //                 ),
      //                 onTap: () {
      //                   _databaseService.deletePlant(plantId);
      //                 },
      //               ),
      //             );
      //           },
      //     );
      //   },
      // ),
    );
  }
}
