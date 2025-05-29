import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutly/models/plant_journal_entry.dart';
import 'package:sproutly/services/database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _descriptionController = TextEditingController(text: widget.entry.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

              // Entry Container (Notes Section) 
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

              // Images Section 
              if (widget.entry.imageUrls.isNotEmpty) ...[
                _buildAllImages(context),
                const SizedBox(height: 24),
              ],

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

  Widget _buildAllImages(BuildContext context) {
    final imageUrls = widget.entry.imageUrls;
    
    if (imageUrls.length == 1) {
      // Single image 
      return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrls.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      // Two images - side by side
      return Row(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.only(right: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.only(left: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[1],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Multiple images 
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      );
    }
  }
}