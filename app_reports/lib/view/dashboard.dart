import 'package:flutter/material.dart';
import 'image_list.dart';
import 'take_images.dart';
import './../main.dart'; // Import your main.dart for navigation back

void main() {
  runApp(Dashboard());
}

class Dashboard extends StatelessWidget {
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

  void _logout() {
    // Navigate back to main.dart (or your login screen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => MianApp()), // Navigate to the main.dart screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32-CAM Control'), // Title for the main screen
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: _logout, // Call logout function
          ),
        ],
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
