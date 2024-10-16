import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart'; // นำเข้าไฟล์ login.dart
import './view/dashboard.dart'; // นำเข้าไฟล์ login.dart

void main() {
  runApp(MianApp());
}

class MianApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32-CAM APP',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // หน้าเริ่มต้น
        '/login': (context) => LoginScreen(), // หน้า login
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบสถานะการล็อกอิน
    if (_isLoggedIn) {
      return Dashboard(); // ถ้าล็อกอินแล้วให้ไปที่หน้า Dashboard
    } else {
      return LoginScreen(); // ถ้ายังไม่ได้ล็อกอินให้ไปที่หน้า Login
    }
  }
}
