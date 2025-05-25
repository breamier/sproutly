import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../cloudinary/pick_image.dart';
import '../cloudinary/upload_image.dart';
import '../services/database_service.dart';

class ImageUploadWidget extends StatelessWidget {
  const ImageUploadWidget({Key? key}) : super(key: key);

  Future<void> handleImageUpload() async {
    final XFile? pickedFile = await pickImage();
    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);

    final String? imageUrl = await uploadImageToCloudinary(imageFile);
    if (imageUrl == null) {
      print('Failed to upload image to Cloudinary');
      return;
    }

    await DatabaseService().saveImageUrlToFirestore(imageUrl);
    print('Image URL saved to Firestore: $imageUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await handleImageUpload();
        },
        child: Text('Upload Image'),
      ),
    );
  }
}
