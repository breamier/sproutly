import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

Future<bool> deleteImageFromCloudinary(String publicId) async {
  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
  final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];

  // need to get signature sign from cloudinary and can't use HTTP basic auth
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
  final signature = sha1.convert(utf8.encode(signatureString)).toString();

  final url = Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/destroy');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'public_id': publicId,
      'api_key': apiKey!,
      'timestamp': timestamp.toString(),
      'signature': signature,
    },
  );

  if (response.statusCode == 200) {
    final respData = jsonDecode(response.body);
    return respData['result'] == 'ok';
  } else {
    return false;
  }
}
