import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'dpxhpivoe';
  const uploadPreset = 'sproutly'; // or use API Key/Secret for signed upload

  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/dpxhpivoe/image/upload',
  );

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final jsonData = json.decode(responseData);
    return jsonData['secure_url']; // Cloudinary image URL
  } else {
    print('Upload failed with status: ${response.statusCode}');
    return null;
  }
}
