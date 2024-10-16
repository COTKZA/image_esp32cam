import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../view/dashboard.dart'; // Import dashboard.dart
import 'register.dart'; // Import register.dart

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/image_esp32cam/auth/login_api.php'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      // Save login status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fit
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      Colors.grey[200], // Light background for the text field
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16), // Space between fields
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      Colors.grey[200], // Light background for the text field
                ),
                obscureText: true,
              ),
              SizedBox(height: 16), // Space between fields
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 16), // Padding for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 16), // Space before register button
              TextButton(
                onPressed: () {
                  // Navigate to RegisterScreen when pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Register'), // Show Register text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
