import 'package:flutter/material.dart';
import '../../models/guidebook.dart';
import 'plant_information_screen.dart';

class GuideBookScreen extends StatefulWidget {
  const GuideBookScreen({super.key});

  @override
  State<GuideBookScreen> createState() => _GuideBookScreenState();
}

class _GuideBookScreenState extends State<GuideBookScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GuideBook> _displayedGuides = [];
  List<GuideBook> _allGuides = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    setState(() => _loading = true);
    final guides = await PlantGuidebook().fetchAllPlants();
    setState(() {
      _allGuides = guides;
      _displayedGuides = guides;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedGuides = _allGuides;
      } else {
        _displayedGuides = _allGuides
            .where(
              (plant) => plant.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF747822);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Guide Book',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Curvilingus',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8D5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: textColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Color(0xFF9A9D6B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.search, color: textColor, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _displayedGuides.isEmpty
                    ? Center(
                        child: Text(
                          'No guidebook entries found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _displayedGuides.length,
                        separatorBuilder: (context, index) => _buildDivider(),
                        itemBuilder: (context, index) {
                          final guide = _displayedGuides[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                guide.plantImage,
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.local_florist),
                              ),
                            ),
                            title: Text(
                              guide.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlantInformationScreen(guide: guide),
                                ),
                              );
                            },
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

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFE0E0C0), thickness: 1.0);
  }
}
