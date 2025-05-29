import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/cloudinary/delete_image.dart';
import 'package:sproutly/cloudinary/upload_image.dart';
import 'package:sproutly/screens/add_plant/add_plant_camera.dart';

class EditPlantForm extends StatefulWidget {
  final String userId;
  final Plant plant;

  const EditPlantForm({super.key, required this.userId, required this.plant});

  @override
  State<EditPlantForm> createState() => _EditPlantFormState();
}

class _EditPlantFormState extends State<EditPlantForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedType;
  String? _selectedWater;
  String? _selectedSunlight;
  String? _selectedCareLevel;
  String? _imageUrl;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  late final Future<List<String>> _typeOptions;
  late final Future<List<String>> _waterOptions;
  late final Future<List<String>> _sunlightOptions;
  late final Future<List<String>> _careOptions;

  String extractCloudinaryPublicId(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      String filename = segments.last;
      int dot = filename.lastIndexOf('.');
      if (dot > 0) {
        return filename.substring(0, dot);
      } else {
        return filename;
      }
    }
    throw Exception("Could not extract publicId from URL");
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.plantName);
    _selectedType = widget.plant.type;
    _selectedWater = widget.plant.water;
    _selectedSunlight = widget.plant.sunlight;
    _selectedCareLevel = widget.plant.careLevel;
    _imageUrl = widget.plant.img;

    final database = Provider.of<DatabaseService>(context, listen: false);
    _typeOptions = database.getDropdownOptions('water-storage-and-adaptation');
    _waterOptions = database.getDropdownOptions('water-level');
    _sunlightOptions = database.getDropdownOptions('sunlight-level');
    _careOptions = database.getDropdownOptions('care-level');
  }

  // Future<void> _deleteImage() async {
  //   if (_imageUrl != null && _imageUrl!.isNotEmpty) {
  //     setState(() => _isUploadingImage = true);
  //     try {
  //       final publicId = extractCloudinaryPublicId(_imageUrl!);
  //       bool success = await deleteImageFromCloudinary(publicId);
  //       if (success) {
  //         await DatabaseService().updatePlantImage(
  //           widget.userId,
  //           widget.plant.id,
  //           null,
  //         );
  //         setState(() {
  //           _imageUrl = null;
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Image deleted successfully.")),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Failed to delete image.")),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Error deleting image: $e")));
  //     } finally {
  //       setState(() => _isUploadingImage = false);
  //     }
  //   }
  // }

  Future<void> _selectNewImage() async {
    final File? newImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPlantCamera(
          addPlant: false,
          onImageSelected: (file) {
            Navigator.pop(context, file);
          },
        ),
      ),
    );
    if (newImage != null) {
      setState(() {
        _isUploadingImage = true;
      });
      try {
        final newUrl = await uploadImageToCloudinary(newImage);
        setState(() {
          _imageUrl = newUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      } finally {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      print('Saving plant with image: $_imageUrl');

      final updatedPlant = widget.plant.copyWith(
        plantName: _nameController.text,
        type: _selectedType,
        water: _selectedWater,
        sunlight: _selectedSunlight,
        careLevel: _selectedCareLevel,
        img: _imageUrl,
      );
      await DatabaseService().updatePlant(
        widget.userId,
        widget.plant.id,
        updatedPlant,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildDropdown({
    required Future<List<String>> future,
    required String? value,
    required String label,
    required String iconPath,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              width: 26,
              height: 26,
              color: const Color(0xFF747822),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF747822),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border.all(color: const Color(0xFF747822), width: 2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border.all(color: const Color(0xFF8B9D3A), width: 2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(child: Text('Failed to load options')),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border.all(color: const Color(0xFF8C8F3E), width: 2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: value,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  hint: Text(
                    'Select $label',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF747822),
                    size: 24,
                  ),
                  items: snapshot.data!
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Please choose an option' : null,
                  onChanged: onChanged,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 75,
        leadingWidth: 75,
        leading: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8D5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF747822), width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF747822),
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Edit Plant',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Curvilingus',
              fontWeight: FontWeight.bold,
              color: Color(0xFF747822),
            ),
          ),
        ),
        titleSpacing: 8,
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: (_imageUrl ?? '').isNotEmpty
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Color(0xFF747822),
                                  ),
                                ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.local_florist,
                              size: 60,
                              color: Color(0xFF747822),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // SELECT NEW IMAGE BUTTON
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Select New Image'),
                  onPressed: _isUploadingImage ? null : _selectNewImage,
                ),
              ),
              if (_isUploadingImage)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),

              const SizedBox(height: 24),
              // Name field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF747822),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      border: Border.all(
                        color: const Color(0xFF8C8F3E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        hintText: 'Enter plant name',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter plant name'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Type dropdown
              _buildDropdown(
                future: _typeOptions,
                value: _selectedType,
                label: 'Type',
                iconPath: 'assets/plant_icon.png',
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 24),
              // Water dropdown
              _buildDropdown(
                future: _waterOptions,
                value: _selectedWater,
                label: 'Water',
                iconPath: 'assets/water_icon.png',
                onChanged: (value) => setState(() => _selectedWater = value),
              ),
              const SizedBox(height: 24),
              // Sunlight dropdown
              _buildDropdown(
                future: _sunlightOptions,
                value: _selectedSunlight,
                label: 'Sunlight',
                iconPath: 'assets/light_icon.png',
                onChanged: (value) => setState(() => _selectedSunlight = value),
              ),
              const SizedBox(height: 24),
              // Care Level dropdown
              _buildDropdown(
                future: _careOptions,
                value: _selectedCareLevel,
                label: 'Care Level',
                iconPath: 'assets/care_icon.png',
                onChanged: (value) =>
                    setState(() => _selectedCareLevel = value),
              ),
              const SizedBox(height: 40),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF747822),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
