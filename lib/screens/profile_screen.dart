import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final data = isLogin
            ? {
          'email': email,
          'password': password,
        }
            : {
          'name': nameController.text,
          'email': email,
          'mobile': mobileController.text,
          'password': password,
          'password_confirmation': passwordConfirmController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Error')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login/Register failed: $e')),
        );
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await apiService.post('/logout', {}, headers: {
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      debugPrint('Logout request failed: $e');
    }
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('userData');

    setState(() {
      isLoggedIn = false;
      email = '';
      token = '';
      userData = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFFD700),
        bottom: isLoggedIn
            ? null
            : TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: isLoggedIn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${userData['name'] ?? ''}'),
            Text('Email: ${userData['email'] ?? ''}'),
            Text('Mobile: ${userData['mobile'] ?? ''}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        )
            : TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => loginOrRegister(true),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: passwordConfirmController,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => loginOrRegister(false),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
