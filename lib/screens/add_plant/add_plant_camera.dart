import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class AddPlantCamera extends StatefulWidget {
  const AddPlantCamera({super.key});

  @override
  State<AddPlantCamera> createState() => _AddPlantCameraState();
}

class _AddPlantCameraState extends State<AddPlantCamera>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
      cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
  }

  Widget _buildUI() {
    if (cameras.isEmpty ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // return CameraPreview(cameraController!);
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.50,
              width: MediaQuery.of(context).size.width * 0.80,
              child: CameraPreview(cameraController!),
            ),
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                size: 40,
                color: Color(0xFF747822),
              ),
              onPressed: () async {
                try {
                  XFile picture = await cameraController!.takePicture();
                  Gal.putImage(picture.path);
                  print('TAKEN PICTURE: ${picture.path}');
                } catch (e) {
                  print('Error taking picture: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
        );
      });
      cameraController
          ?.initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
          })
          .catchError((e) {
            print('Error initializing camera: $e');
          });
    } else {
      throw Exception('No cameras available');
    }
  }
}
