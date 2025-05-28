import 'package:flutter/material.dart';

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
  final String title;
  final String description;
  final String imagePath;
  final String date;

  const GrowthJournalIndivEntry({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.date,
  });

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
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
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

              // Image
              Image.asset(
                widget.imagePath,
                width: screenWidth * 0.3,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

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
                          widget.date,
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
                  onPressed: () {
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
