import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sproutly/screens/dashboard_screen.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:sproutly/models/plant.dart';
import 'package:sproutly/cloudinary/upload_image.dart';

class AddNewPlant extends StatefulWidget {
  final File? imageFile;
  const AddNewPlant({super.key, this.imageFile});

  @override
  State<AddNewPlant> createState() => _AddNewPlantState();
}

class _AddNewPlantState extends State<AddNewPlant> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _imageUrl;

  bool _isSaving = false;
  String? _selectedType;
  String? _selectedWater;
  String? _selectedSunlight;
  String? _selectedCareLevel;

  // Error messages for validation
  String? _nameError;
  String? _typeError;
  String? _waterError;
  String? _sunlightError;
  String? _careError;

  // cache dropdown options to avoid fetching over and over again
  late final Future<List<String>> _typeOptions;
  late final Future<List<String>> _waterOptions;
  late final Future<List<String>> _sunlightOptions;
  late final Future<List<String>> _careOptions;

  @override
  void initState() {
    super.initState();
    // fetch different categories
    final database = Provider.of<DatabaseService>(context, listen: false);
    _typeOptions = database.getDropdownOptions('water-storage-and-adaptation');
    _waterOptions = database.getDropdownOptions('water-level');
    _sunlightOptions = database.getDropdownOptions('sunlight-level');
    _careOptions = database.getDropdownOptions('care-level');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // reset after submitting form
  void _resetForm() {
    _nameController.clear();
    _imageUrl = null;
    setState(() {
      _selectedType = null;
      _selectedWater = null;
      _selectedSunlight = null;
      _selectedCareLevel = null;
      _isSaving = false;
      _imageUrl = null;
      _nameError = null;
      _typeError = null;
      _waterError = null;
      _sunlightError = null;
      _careError = null;
    });
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Please enter plant name' : null;
      _typeError = _selectedType == null ? 'Please choose an option' : null;
      _waterError = _selectedWater == null ? 'Please choose an option' : null;
      _sunlightError = _selectedSunlight == null ? 'Please choose an option' : null;
      _careError = _selectedCareLevel == null ? 'Please choose an option' : null;
    });

    if (_nameError != null || _typeError != null || _waterError != null || _sunlightError != null || _careError != null) {
      isValid = false;
    }

    return isValid;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.imageFile != null) {
        _imageUrl = await uploadImageToCloudinary(widget.imageFile!);
      }
      final plant = Plant(
        id: '',
        plantName: _nameController.text,
        type: _selectedType,
        water: _selectedWater ?? '',
        sunlight: _selectedSunlight ?? '',
        careLevel: _selectedCareLevel ?? '',
        addedOn: Timestamp.now(),
        img: _imageUrl ?? '',
      );

      final database = Provider.of<DatabaseService>(context, listen: false);
      database.addPlant(plant);

      if (mounted) {
        _resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant added successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildDropdown({
    required Future<List<String>> future,
    required String? value,
    required String label,
    required String iconPath,
    required ValueChanged<String?> onChanged,
    required String? errorText,
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
                  border: Border.all(
                    color: errorText != null ? Colors.red : const Color(0xFF747822), 
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(child: LinearProgressIndicator()),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border.all(
                    color: errorText != null ? Colors.red : const Color(0xFF8B9D3A), 
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(child: Text('Failed to load options')),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border.all(
                  color: errorText != null ? Colors.red : const Color(0xFF8C8F3E), 
                  width: 2
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Select $label',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF747822),
                      size: 24,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF747822),
                    fontSize: 16,
                  ),
                  items: snapshot.data!
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF747822),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    onChanged(newValue);
                    // Clear error when user selects an option
                    setState(() {
                      if (label == 'Type') _typeError = null;
                      if (label == 'Water') _waterError = null;
                      if (label == 'Sunlight') _sunlightError = null;
                      if (label == 'Care Level') _careError = null;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return snapshot.data!.map<Widget>((String item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF747822),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            );
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 20),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
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
            border: Border.all(
              color: const Color(0xFF747822),
              width: 1.5,
            ),
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
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: const Text(
            'New Plant',
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
              // Name field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/plant_icon.png',
                        width: 26,
                        height: 26,
                        color: const Color(0xFF747822),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF747822),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      border: Border.all(
                        color: _nameError != null ? Colors.red : const Color(0xFF8C8F3E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        hintText: 'Enter plant name',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF747822),
                      ),
                      onChanged: (value) {
                        // Clear error when user types
                        if (_nameError != null && value.trim().isNotEmpty) {
                          setState(() {
                            _nameError = null;
                          });
                        }
                      },
                    ),
                  ),
                  if (_nameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 20),
                      child: Text(
                        _nameError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
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
                errorText: _typeError,
              ),
              const SizedBox(height: 24),

              // Water dropdown
              _buildDropdown(
                future: _waterOptions,
                value: _selectedWater,
                label: 'Water',
                iconPath: 'assets/water_icon.png',
                onChanged: (value) => setState(() => _selectedWater = value),
                errorText: _waterError,
              ),
              const SizedBox(height: 24),

              // Sunlight dropdown
              _buildDropdown(
                future: _sunlightOptions,
                value: _selectedSunlight,
                label: 'Sunlight',
                iconPath: 'assets/light_icon.png',
                onChanged: (value) => setState(() => _selectedSunlight = value),
                errorText: _sunlightError,
              ),
              const SizedBox(height: 24),

              // Care Level dropdown
              _buildDropdown(
                future: _careOptions,
                value: _selectedCareLevel,
                label: 'Care Level',
                iconPath: 'assets/care_icon.png',
                onChanged: (value) => setState(() => _selectedCareLevel = value),
                errorText: _careError,
              ),
              const SizedBox(height: 40),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
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
                          'Save new plant',
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