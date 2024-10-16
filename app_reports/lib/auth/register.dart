import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false; // Variable for loading status

  Future<void> _register() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Set loading status to true
    setState(() {
      _isLoading = true;
    });

    // Send request to the API
    final response = await http.post(
      Uri.parse('http://127.0.0.1/image_esp32cam/auth/registration_api.php'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    final data = json.decode(response.body);

    // Check API response
    if (data['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );
      // Clear form after successful registration
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate back to the login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }

    // Set loading status to false
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
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
                  'Create Account',
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
                      Colors.grey[200], // Light background for text field
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
                      Colors.grey[200], // Light background for text field
                ),
                obscureText: true,
              ),
              SizedBox(height: 16), // Space between fields
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      Colors.grey[200], // Light background for text field
                ),
                obscureText: true,
              ),
              SizedBox(height: 20), // Space before button
              _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 16), // Padding for button
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
