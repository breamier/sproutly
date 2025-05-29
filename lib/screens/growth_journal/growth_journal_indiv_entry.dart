import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutly/models/plant_journal_entry.dart';
import 'package:sproutly/services/database_service.dart';

// cloudinary delete image
import '../../cloudinary/delete_image.dart';

const Color oliveGreen = Color(0xFF747822);

const TextStyle titleFont = TextStyle(
  fontFamily: 'Curvilingus',
  fontWeight: FontWeight.w700,
  fontSize: 38,
  color: oliveGreen,
);

const TextStyle headingFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w700,
  fontSize: 18,
  color: oliveGreen,
);

const TextStyle bodyFont = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
  fontSize: 12,
  color: oliveGreen,
);

class GrowthJournalIndivEntry extends StatefulWidget {
  final PlantJournalEntry entry;

  const GrowthJournalIndivEntry({super.key, required this.entry});

  @override
  State<GrowthJournalIndivEntry> createState() =>
      _GrowthJournalIndivEntryState();
}

class _GrowthJournalIndivEntryState extends State<GrowthJournalIndivEntry> {
  bool isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late List<String> _imageUrls;
  bool _isDeletingImage = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _descriptionController = TextEditingController(text: widget.entry.notes);
    _imageUrls = List<String>.from(widget.entry.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String extractCloudinaryPublicId(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    if (segments.length >= 5) {
      String filename = segments.last; // <public_id>.<ext>
      int dot = filename.lastIndexOf('.');
      if (dot > 0) {
        return filename.substring(0, dot);
      } else {
        return filename;
      }
    }
    throw Exception("Could not extract publicId from URL");
  }

  Future<void> _deleteImage(String url) async {
    setState(() {
      _isDeletingImage = true;
    });

    try {
      String publicId = extractCloudinaryPublicId(url);
      print('Deleting Cloudinary publicId: $publicId');

      bool success = await deleteImageFromCloudinary(publicId);

      if (success) {
        setState(() {
          _imageUrls.remove(url);
        });

        // Update Firestore/Database as needed
        final updatedEntry = PlantJournalEntry(
          id: widget.entry.id,
          plantId: widget.entry.plantId,
          title: _titleController.text.trim(),
          notes: _descriptionController.text.trim(),
          createdAt: widget.entry.createdAt,
          imageUrls: _imageUrls,
        );

        final dbService = DatabaseService();
        await dbService.updateJournalEntry(
          widget.entry.plantId,
          widget.entry.id,
          updatedEntry,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete image.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting image: $e")));
    } finally {
      setState(() {
        _isDeletingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
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
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF8C8F3E),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Growth Journal',
                      style: TextStyle(
                        fontFamily: 'Curvilingus',
                        fontWeight: FontWeight.w700,
                        fontSize: (MediaQuery.of(context).size.width * 0.08)
                            .clamp(24.0, 38.0),
                        color: const Color(0xFF747822),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      color: oliveGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Editable Title
              isEditing
                  ? TextField(
                      controller: _titleController,
                      style: headingFont.copyWith(fontSize: screenWidth * 0.05),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Title',
                      ),
                    )
                  : Text(
                      _titleController.text,
                      style: headingFont.copyWith(fontSize: screenWidth * 0.05),
                    ),

              const SizedBox(height: 16),

              // image with delete buttons
              if (_imageUrls.isNotEmpty)
                Column(
                  children: [
                    for (var url in _imageUrls)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.network(
                              url,
                              width: screenWidth * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              right: 0,
                              child: _isDeletingImage
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await _deleteImage(url);
                                      },
                                    ),
                            ),
                        ],
                      ),
                  ],
                ),

              // Entry Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: oliveGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notes Header + Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notes', style: headingFont),
                        Text(
                          DateFormat(
                            'MMMM d, y, h:mm a',
                          ).format(widget.entry.createdAt.toDate()),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Editable or Static Description
                    isEditing
                        ? TextField(
                            controller: _descriptionController,
                            style: bodyFont.copyWith(
                              fontSize: screenWidth * 0.035,
                            ),
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Write your journal entry...',
                            ),
                          )
                        : Text(
                            _descriptionController.text,
                            style: bodyFont.copyWith(
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              if (isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oliveGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final notes = _descriptionController.text.trim();
                    print("Title: $title, Notes: $notes");
                    // Validate input

                    if (title.isEmpty && notes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill in the fields."),
                        ),
                      );
                      return;
                    }

                    final updatedEntry = PlantJournalEntry(
                      id: widget.entry.id,
                      plantId: widget.entry.plantId,
                      title: title,
                      notes: notes,
                      createdAt: widget.entry.createdAt,
                      imageUrls: widget.entry.imageUrls,
                    );

                    final dbService = DatabaseService();
                    await dbService.updateJournalEntry(
                      widget.entry.plantId,
                      widget.entry.id,
                      updatedEntry,
                    );

                    setState(() {
                      isEditing = false;
                    });
                  },
                  child: const Text(
                    'Save Journal Entry',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
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
