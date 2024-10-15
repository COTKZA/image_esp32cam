import 'package:flutter/material.dart';
import 'view/image_list.dart';
import 'view/take_images.dart';

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

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track the currently selected index

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    take_images(), // Screen for taking images
    ImageListScreen(), // Screen for viewing images
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32-CAM Control'), // Title for the main screen
      ),
      body: _screens[_selectedIndex], // Display the currently selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'View Images',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected item
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped, // Handle item tap
      ),
    );
  }
}
