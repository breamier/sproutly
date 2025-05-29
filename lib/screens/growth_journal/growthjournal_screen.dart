import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sproutly/cloudinary/upload_image.dart';
import 'package:sproutly/models/plant_journal_entry.dart';
import 'package:sproutly/screens/add_plant/add_plant_camera.dart';
import 'package:sproutly/services/database_service.dart';

class GrowthJournalScreen extends StatefulWidget {
  final String plantId;
  const GrowthJournalScreen({super.key, required this.plantId});

  static const Color oliveGreen = Color(0xFF747822);

  static const TextStyle titleFont = TextStyle(
    fontFamily: 'Curvilingus',
    fontWeight: FontWeight.w700,
    fontSize: 40,
    color: oliveGreen,
  );

  static const TextStyle headingFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: oliveGreen,
  );

  static const TextStyle bodyFont = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: oliveGreen,
  );

  @override
  State<GrowthJournalScreen> createState() => _GrowthJournalScreenState();
}

class _GrowthJournalScreenState extends State<GrowthJournalScreen> {
  final List<String> imagePaths = [];
  final List<String> imageUrls = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitJournalEntry() async {
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();

    if (title.isEmpty && notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the fields.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      imageUrls.clear();
      for (final path in imagePaths) {
        final url = await uploadImageToCloudinary(File(path));
        if (url != null && url.isNotEmpty) {
          imageUrls.add(url);
        }
      }

      final journalEntry = PlantJournalEntry(
        id: '',
        plantId: widget.plantId,
        title: title,
        notes: notes,
        createdAt: Timestamp.now(),
        imageUrls: imageUrls,
      );

      await DatabaseService().addJournalEntry(widget.plantId, journalEntry);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving journal entry: $e")));
    } finally {
      setState(() {
        isSaving = false;
        _titleController.clear();
        _notesController.clear();
        imagePaths.clear();
        imageUrls.clear();
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 5.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C8F3E).withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8C8F3E),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8C8F3E),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Growth Journal",
                    style: TextStyle(
                      fontFamily: 'Curvilingus',
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      color: GrowthJournalScreen.oliveGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: DatabaseService().getPlantById(widget.plantId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            "Loading...",
                            style: GrowthJournalScreen.headingFont,
                          );
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            "Plant not found",
                            style: GrowthJournalScreen.headingFont,
                          );
                        }
                        final plant = snapshot.data!;
                        return Text(
                          "${plant.plantName} Notes",
                          style: GrowthJournalScreen.headingFont,
                        );
                      },
                    ),

                    Container(
                      width: double.infinity,
                      height: 300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: GrowthJournalScreen.oliveGreen,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              hintStyle: GrowthJournalScreen.headingFont,
                              border: InputBorder.none,
                            ),
                            style: GrowthJournalScreen.headingFont,
                          ),
                          SizedBox(height: 8),
                          Flexible(
                            child: TextField(
                              controller: _notesController,
                              maxLines: null,
                              expands: true,
                              style: GrowthJournalScreen.bodyFont,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Photos",
                      style: GrowthJournalScreen.headingFont,
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.2 * 1.30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePaths.length + 1,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index < imagePaths.length) {
                            return _buildPhoto(context, imagePaths[index]);
                          } else {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AddPlantCamera(
                                          addPlant: false,
                                          onImageSelected: (File imageFile) {
                                            setState(() {
                                              imagePaths.add(imageFile.path);
                                            });
                                          },
                                        ),
                                  ),
                                );
                                print("Image selected: ${imagePaths.first}");
                              },
                              child: _buildAddPhotoBox(context),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    Center(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submitJournalEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GrowthJournalScreen.oliveGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child:
                            isSaving
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
                                  "Save  Journal Entry",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(BuildContext context, String path) {
    final screenWidth = MediaQuery.of(context).size.width;
    final photoWidth = screenWidth * 0.2;

    return SizedBox(
      width: photoWidth,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildAddPhotoBox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.2;

    return SizedBox(
      width: boxWidth,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 136, 123, 123)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: Color.fromARGB(255, 136, 123, 123),
                ),
                SizedBox(height: 4),
                Text(
                  "Add new photo",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    color: Color.fromARGB(255, 136, 123, 123),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
