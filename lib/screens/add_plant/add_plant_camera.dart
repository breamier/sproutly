import 'dart:io';
import 'package:sproutly/screens/add_plant/add_plant_form.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AddPlantCamera extends StatefulWidget {
  const AddPlantCamera({super.key});

  @override
  State<AddPlantCamera> createState() => _AddPlantCameraState();
}

class _AddPlantCameraState extends State<AddPlantCamera>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  XFile? _capturedImage;
  File? _pickedImage;
  bool _fromCamera = false;

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
              child:
                  _capturedImage != null
                      ? Image.file(File(_capturedImage!.path))
                      : _pickedImage != null
                      ? Image.file(_pickedImage!)
                      : CameraPreview(cameraController!),
            ),
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                size: 40,
                color: Color(0xFF747822),
              ),
              onPressed: () async {
                if (_capturedImage == null && _pickedImage == null) {
                  try {
                    XFile picture = await cameraController!.takePicture();
                    setState(() {
                      _capturedImage = picture;
                      _pickedImage = null;
                      _fromCamera = true;
                    });
                    _showConfirmDialog(File(picture.path), fromCamera: true);
                    // Gal.putImage(picture.path);
                    // print('TAKEN PICTURE: ${picture.path}');
                  } catch (e) {
                    print('Error taking picture: $e');
                  }
                } else {
                  setState(() {
                    _capturedImage = null;
                    _pickedImage = null;
                  });
                }
              },
            ),
            const SizedBox(width: 32),
            IconButton(
              icon: const Icon(
                Icons.upload_file,
                size: 40,
                color: Color(0xFF747822),
              ),
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  setState(() {
                    _pickedImage = File(picked.path);
                    _capturedImage = null;
                    _fromCamera = false;
                  });
                  _showConfirmDialog(File(picked.path), fromCamera: false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<File> _cropToSquare(File file) async {
  //   final bytes = await file.readAsBytes();
  //   img.Image? original = img.decodeImage(bytes);
  //   if (original == null) return file;

  //   int size =
  //       original.width < original.height ? original.width : original.height;
  //   int offsetX = (original.width - size) ~/ 2;
  //   int offsetY = (original.height - size) ~/ 2;

  //   img.Image cropped = img.copyCrop(
  //     original,
  //     x: offsetX,
  //     y: offsetY,
  //     width: size,
  //     height: size,
  //   );
  //   final croppedBytes = img.encodeJpg(cropped);

  //   final croppedFile = await file.writeAsBytes(croppedBytes, flush: true);
  //   return croppedFile;
  // }

  Future<void> _showConfirmDialog(
    File imageFile, {
    required bool fromCamera,
  }) async {
    // File squareFile = await _cropToSquare(imageFile);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save this picture?'),
            content: Image.file(imageFile),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Discard
                },
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Save
                },
                child: const Text('Use'),
              ),
            ],
          ),
    );
    if (result == true) {
      if (fromCamera) {
        Gal.putImage(imageFile.path);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Picture saved!')));
        setState(() {
          _capturedImage = null; // Reset to camera preview
          _pickedImage = null;
        });
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewPlant(imageFile: imageFile),
        ),
      );
    } else {
      setState(() {
        _capturedImage = null;
        _pickedImage = null;
      });
    }
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
