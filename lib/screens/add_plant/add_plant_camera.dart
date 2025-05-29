import 'dart:io';
import 'package:sproutly/screens/add_plant/add_plant_form.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AddPlantCamera extends StatefulWidget {
  final bool addPlant; // Flag to determine if it's for adding a plant
  final void Function(File imageFile)? onImageSelected;

  const AddPlantCamera({super.key, this.addPlant = true, this.onImageSelected});

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
  bool _showPreview = false;

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
  void dispose() {
    cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildUI());
  }

  Widget _buildUI() {
    if (cameras.isEmpty ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          // Custom App Bar
          _buildAppBar(),

          // Main Content
          Expanded(
            child: _showPreview ? _buildPreviewScreen() : _buildCameraScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8D5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF747822), width: 2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.chevron_left,
                color: Color(0xFF747822),
                size: 24,
              ),
              onPressed: () {
                if (_showPreview) {
                  setState(() {
                    _showPreview = false;
                    _capturedImage = null;
                    _pickedImage = null;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'New Plant',
            style: TextStyle(
              fontFamily: 'Curvilingus',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF747822),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScreen() {
    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Take a picture of your plant first!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: const Color(0xFF747822),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Camera Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CameraPreview(cameraController!),
            ),
          ),
        ),

        // Camera Controls
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery Button
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF747822),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF747822),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: const Color(0xFF747822),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Camera Button
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF747822),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              // Spacer for symmetry
              const SizedBox(width: 60),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewScreen() {
    File? imageFile =
        _capturedImage != null ? File(_capturedImage!.path) : _pickedImage;

    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Take a picture of your plant first!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: const Color(0xFF747822),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Image Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imageFile != null
                      ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                      : const SizedBox(),
            ),
          ),
        ),

        // Camera Icon (Satisfied with picture?)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF747822),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
        ),

        // Question Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Satisfied with the picture?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: const Color(0xFF747822),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Continue Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _continueToForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF747822),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Retake Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _retakePicture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF747822).withOpacity(0.65),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Retake',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _takePicture() async {
    try {
      XFile picture = await cameraController!.takePicture();
      setState(() {
        _capturedImage = picture;
        _pickedImage = null;
        _fromCamera = true;
        _showPreview = true;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _capturedImage = null;
        _fromCamera = false;
        _showPreview = true;
      });
    }
  }

  void _retakePicture() {
    setState(() {
      _showPreview = false;
      _capturedImage = null;
      _pickedImage = null;
    });
  }

  void _continueToForm() async {
    File? imageFile =
        _capturedImage != null ? File(_capturedImage!.path) : _pickedImage;

    if (imageFile != null) {
      // Save to gallery if taken from camera
      if (_fromCamera && _capturedImage != null) {
        await Gal.putImage(_capturedImage!.path);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Picture saved!')));
      }

      if (widget.addPlant) {
        await cameraController?.dispose();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddNewPlant(imageFile: imageFile),
          ),
        );
      } else if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);
        await cameraController?.dispose();
        Navigator.pop(context); // Go back to journal entry screen
      }
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
