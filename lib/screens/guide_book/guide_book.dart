import 'package:flutter/material.dart';
import 'package:sproutly/models/plant_category_item.dart';
import 'package:sproutly/models/plant_category_model.dart';
import 'package:sproutly/services/plant_data_service.dart';

class GuideBookScreen extends StatefulWidget {
  final List<PlantCategory>? categories;
  
  const GuideBookScreen({
    super.key,
    this.categories,
  });

  @override
  State<GuideBookScreen> createState() => _GuideBookScreenState();
}

class _GuideBookScreenState extends State<GuideBookScreen> {
  late final TextEditingController _searchController;
  late List<PlantCategory> _displayedCategories;
  final _plantDataService = PlantDataService();
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _displayedCategories = widget.categories ?? _plantDataService.getDefaultCategories();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedCategories = widget.categories ?? _plantDataService.getDefaultCategories();
      } else {
        _displayedCategories = _plantDataService.searchCategories(query);
      }
    });
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
                      child: Icon(
                        Icons.search,
                        color: textColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView.separated(
                  itemCount: _displayedCategories.length,
                  separatorBuilder: (context, index) => _buildDivider(),
                  itemBuilder: (context, index) {
                    return PlantCategoryItem.fromModel(
                      category: _displayedCategories[index],
                      textColor: textColor,
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
    return const Divider(
      color: Color(0xFFE0E0C0), 
      thickness: 1.0,
    );
  }
}