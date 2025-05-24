import 'package:flutter/material.dart';
import 'package:sproutly/screens/guide_book/plant_information_screen.dart';
import 'plant_category_model.dart';

class PlantCategoryItem extends StatelessWidget {
  final String title;
  final String imageName;
  final Color textColor;
  final String description;
  final String careTip;

  const PlantCategoryItem({
    super.key,
    required this.title,
    required this.imageName,
    required this.textColor,
    required this.description,
    required this.careTip,
  });

  factory PlantCategoryItem.fromModel({
    required PlantCategory category,
    required Color textColor,
  }) {
    return PlantCategoryItem(
      title: category.title,
      imageName: category.imageName,
      textColor: textColor,
      description: category.description,
      careTip: category.careTip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlantInformationScreen(
                  plantType: title,
                  plantImage: imageName,
                  plantDescription: description,
                  careTip: careTip,
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Image.asset('assets/$imageName', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
