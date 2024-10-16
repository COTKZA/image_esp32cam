// image_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_data_model.dart';

class ApiService {
  final String apiUrl = 'http://10.0.2.2/image_esp32cam/api/api_ai_check.php';

  Future<List<ImageData>> fetchImages() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((image) => ImageData.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<List<ImageData>> fetchNewImages(String lastId) async {
    final response = await http.get(Uri.parse('$apiUrl?lastId=$lastId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((image) => ImageData.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load new images');
    }
  }

  Future<void> deleteImage(String id) async {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': id},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image: ${response.body}');
    }
  }
}
