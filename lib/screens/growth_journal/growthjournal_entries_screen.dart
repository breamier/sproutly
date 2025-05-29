import 'package:flutter/material.dart';
import 'package:sproutly/screens/growth_journal/growth_journal_indiv_entry.dart';
import 'package:sproutly/screens/growth_journal/growthjournal_screen.dart';
import 'package:sproutly/services/database_service.dart';
import 'package:sproutly/models/plant_journal_entry.dart';
import 'package:intl/intl.dart';

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

class GrowthJournalEntriesScreen extends StatefulWidget {
  final String plantId;
  const GrowthJournalEntriesScreen({super.key, required this.plantId});

  @override
  State<GrowthJournalEntriesScreen> createState() =>
      _GrowthJournalEntriesScreenState();
}

class _GrowthJournalEntriesScreenState
    extends State<GrowthJournalEntriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: oliveGreen,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GrowthJournalScreen(plantId: widget.plantId),
            ),
          );
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    'Growth Journal',
                    style: TextStyle(
                      fontFamily: 'Curvilingus',
                      fontWeight: FontWeight.w700,
                      fontSize: (MediaQuery.of(context).size.width * 0.08)
                          .clamp(24.0, 38.0),
                      color: const Color(0xFF747822),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Text('My Entries', style: headingFont.copyWith(fontSize: 22)),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: DatabaseService().getJournalEntries(widget.plantId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No journal entries yet.'),
                      );
                    }
                    final entries =
                        snapshot.data!.docs.map((doc) => doc.data()).toList();
                    return ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder:
                          (context, index) =>
                              _buildJournalEntry(context, entries[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntry(BuildContext context, PlantJournalEntry entry) {
    final formattedDate = DateFormat(
      'MMMM d, y, h:mm a',
    ).format(entry.createdAt.toDate());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrowthJournalIndivEntry(entry: entry),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4F4),
          border: Border.all(color: oliveGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images section
            if (entry.imageUrls.isNotEmpty) ...[
              _buildJournalImages(entry.imageUrls),
              const SizedBox(height: 16),
            ],
            
            // Title
            Text(entry.title, style: headingFont),
            const SizedBox(height: 8),
            
            // Notes preview
            Text(
              entry.notes,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: bodyFont,
            ),
            const SizedBox(height: 12),
            
            // Date
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 40, color: Colors.grey),
        ),
      );
    }

    if (imageUrls.length == 1) {
      // Single image
      return Container(
        height: 120,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrls[0],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      // Two images side by side
      return SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(
              child: Container(
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
        ),
      );
    } else {
      final displayImages = imageUrls.take(3).toList();
      final extraCount = imageUrls.length - 3;

      return SizedBox(
        height: 120,
        child: Row(
          children: [
            // Main image (2/3 width)
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    displayImages[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
            ),
            // Side images (1/3 width)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Second image
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 4, bottom: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          displayImages[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Third image or +more overlay
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(left: 4, top: 2),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: displayImages.length > 2
                              ? Image.network(
                                  displayImages[2],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, size: 20),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                ),
                          ),
                          if (extraCount > 0)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+$extraCount',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
          ],
        ),
      );
    }
  }
}