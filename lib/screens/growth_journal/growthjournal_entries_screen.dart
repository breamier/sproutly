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
            builder:
                (context) => GrowthJournalIndivEntry(
                  title: entry.title,
                  description: entry.notes,
                  imagePath:
                      entry.imageUrls.isNotEmpty ? entry.imageUrls.first : '',
                  date: formattedDate,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4F4),
          border: Border.all(color: oliveGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJournalImages(entry.imageUrls),
            const SizedBox(height: 12),
            Text(entry.title, style: headingFont),
            const SizedBox(height: 4),
            Text(entry.notes, maxLines: 3, style: bodyFont),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.grey,
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
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 40)),
      );
    }

    // Show up to 4 images, others are +extra
    final imagesToShow = imageUrls.take(4).toList();
    final extraCount = imageUrls.length - imagesToShow.length;

    return Row(
      children: [
        for (int i = 0; i < imagesToShow.length; i++) ...[
          Expanded(
            flex: 2,
            child: Container(
              height: 150,
              margin: EdgeInsets.only(
                right: i < imagesToShow.length - 1 ? 8 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagesToShow[i],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                ),
              ),
            ),
          ),
        ],
        if (extraCount > 0)
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrls[3]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$extraCount',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}
