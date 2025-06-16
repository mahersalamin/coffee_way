import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool isLoggedIn = false;
  String email = '';
  String token = '';
  Map<String, dynamic> userData = {};

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final apiService = ApiService();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedToken = prefs.getString('token');
    final savedUserData = prefs.getString('userData');

    if (savedEmail != null && savedToken != null && savedUserData != null) {
      setState(() {
        email = savedEmail;
        token = savedToken;
        isLoggedIn = true;
        userData = json.decode(savedUserData);
      });
    }
  }

  Future<void> loginOrRegister(bool isLogin) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please fill in all required fields.');
      return;
    }

    try {
      final data = isLogin
          ? {
        'email': email,
        'password': password,
      }
          : {
        'name': nameController.text.trim(),
        'email': email,
        'mobile': mobileController.text.trim(),
        'password': password,
        'password_confirmation': passwordConfirmController.text.trim(),
      };

      final response = await apiService.post(
        isLogin ? '/login' : '/register',
        data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('token', token);
        await prefs.setString('userData', json.encode(user));

        setState(() {
          this.email = email;
          this.token = token;
          isLoggedIn = true;
          userData = user;
        });
      } else {
        showMessage(response.data['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      showMessage('Login/Register failed: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await apiService.post('/logout', {}, options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ));
    } catch (_) {}

    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      email = '';
      token = '';
      userData = {};
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFFFF3CD),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFFFFD700),
        centerTitle: true,
        bottom: isLoggedIn
            ? null
            : TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'تسجيل الدخول'),
            Tab(text: 'إنشاء حساب'),
          ],
        ),
      ),
      body: isLoggedIn
          ? Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات المستخدم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: Text(userData['name'] ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.black87),
              title: Text(userData['email'] ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.black87),
              title: Text(userData['mobile'] ?? ''),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Login Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: inputDecoration('البريد الإلكتروني'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: inputDecoration('كلمة المرور'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => loginOrRegister(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ),
          // Register Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: inputDecoration('الاسم'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: inputDecoration('البريد الإلكتروني'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: mobileController,
                    decoration: inputDecoration('رقم الجوال'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: inputDecoration('كلمة المرور'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordConfirmController,
                    decoration: inputDecoration('تأكيد كلمة المرور'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => loginOrRegister(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('إنشاء حساب'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
