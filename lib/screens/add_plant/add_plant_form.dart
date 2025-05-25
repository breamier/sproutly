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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String? _imageUrl;

  bool _isSaving = false;
  String? _selectedType;
  String? _selectedWater;
  String? _selectedSunlight;
  String? _selectedCareLevel;

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
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // reset after submitting form
  void _resetForm() {
    _nameController.clear();
    _dateController.clear();
    _timeController.clear();
    _imageUrl = null;
    setState(() {
      _selectedType = null;
      _selectedWater = null;
      _selectedSunlight = null;
      _selectedCareLevel = null;
      _isSaving = false;
      _imageUrl = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.imageFile != null) {
        _imageUrl = await uploadImageToCloudinary(widget.imageFile!);
      }
      final plant = Plant(
        id: '',
        plantName: _nameController.text,
        waterStorage: _selectedType,
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

  // Future<void> _selectDate(BuildContext context) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
  //   }
  // }

  // Future<void> _selectTime(BuildContext context) async {
  //   final picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (picked != null) {
  //     _timeController.text = picked.format(context);
  //   }
  // }

  Widget _buildDropdown({
    required Future<List<String>> future,
    required String? value,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder<List<String>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Failed to load options');
        }
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label),
          items:
              snapshot.data!
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),

          validator:
              (value) => value == null ? 'Please Choose an Option' : null,
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Plant'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please Select Plant Name'
                            : null,
              ),
              // const SizedBox(height: 16),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //     controller: _dateController,
              //     decoration: const InputDecoration(
              //       labelText: 'Date',
              //       border: OutlineInputBorder(),
              //       suffixIcon: Icon(Icons.calendar_today),
              //     ),
              //     readOnly: true,
              //     onTap: () => _selectDate(context),
              //     validator:
              //         (value) =>
              //             value?.isEmpty ?? true
              //                 ? 'Please Select Date'
              //                 : null,
              //   ),
              // ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: TextFormField(
              //     controller: _timeController,
              //         decoration: const InputDecoration(
              //           labelText: 'Time',
              //           border: OutlineInputBorder(),
              //           suffixIcon: Icon(Icons.access_time),
              //         ),
              //         readOnly: true,
              //         onTap: () => _selectTime(context),
              //         validator:
              //             (value) =>
              //                 value?.isEmpty ?? true
              //                     ? 'Please Select Time'
              //                     : null,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 16),
              _buildDropdown(
                future: _typeOptions,
                value: _selectedType,
                label: 'Type',
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                future: _waterOptions,
                value: _selectedWater,
                label: 'Water',
                onChanged: (value) => setState(() => _selectedWater = value),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                future: _sunlightOptions,
                value: _selectedSunlight,
                label: 'Sunlight',
                onChanged: (value) => setState(() => _selectedSunlight = value),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                future: _careOptions,
                value: _selectedCareLevel,
                label: 'Care Level',
                onChanged:
                    (value) => setState(() => _selectedCareLevel = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF747822),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Save New Plant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
