import 'package:flutter/material.dart';
// Import your ApiService
import 'package:ticket/home_page.dart';
import 'package:ticket/login_page.dart';
import 'package:ticket/register_page.dart';
import 'package:ticket/services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService _apiService = ApiService(); // Instance of ApiService

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GraphixUI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _apiService.verifySession(), // Verify session on app startup
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading
          } else if (snapshot.hasError || snapshot.data == false) {
            // Navigate to login if session is invalid
            return LoginPage();
          } else {
            // Navigate to home if session is valid
            return HomePage();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
