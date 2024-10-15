import 'package:flutter/material.dart';
import 'take_photo/capture_page.dart'; // Import your camera capture screen
import 'images_list/image_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32-CAM Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // Set MainScreen as the home screen
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32-CAM Control'), // Title for the main screen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 5, // Shadow effect
              ),
              onPressed: () {
                // Navigate to Capture Image screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text(
                'Capture',
                style: TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 5, // Shadow effect
              ),
              onPressed: () {
                // Navigate to Image List screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageList()),
                );
              },
              child: Text(
                'View Images',
                style: TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
