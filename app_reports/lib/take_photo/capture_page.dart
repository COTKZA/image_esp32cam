import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatelessWidget {
  // Replace with your ESP32-CAM IP address
  final String esp32CamUrl = 'http://192.168.137.193/capture';

  Future<void> captureImage() async {
    try {
      // Send a GET request to the ESP32-CAM
      final response = await http.get(Uri.parse(esp32CamUrl));

      if (response.statusCode == 200) {
        // Successfully captured the image
        print('Image captured: ${response.body}');
        // You can show a success message or perform additional actions here
      } else {
        print('Failed to capture image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Background color
            foregroundColor: Colors.white, // Text color
            padding:
                EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            elevation: 5, // Shadow effect
          ),
          onPressed: captureImage,
          child: Text(
            'Capture Image',
            style: TextStyle(
              fontSize: 18, // Text size
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ),
      ),
    );
  }
}
