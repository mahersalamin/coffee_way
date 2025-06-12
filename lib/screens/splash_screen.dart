import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFD700), // Yellow background
      body: Center(
        child: Text(
          'Welcome to Coffee Way',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFD32F2F), // Red text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
