import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  final String baseUrl = "https://api.ticketverz.com/api";
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final signature = await storage.read(key: 'attendee_signature');
      if (signature == null) {
        print("No attendee signature found. User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view profile')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-session'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'Attendee-Signature=$signature',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "Ok" && data['code'] == 200) {
          setState(() {
            profileData = data['data'];
            isLoading = false;
          });
        } else {
          print("Failed to fetch profile data: ${data['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch profile data')),
          );
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch profile data')),
        );
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching profile data')),
      );
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'attendee_signature');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 6, 1, 66),
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 1, 66),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Neumorphic container for Name
            NeumorphicContainer(
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    profileData?['first_name'] ?? 'N/A',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Neumorphic container for Email
            NeumorphicContainer(
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    profileData?['email'] ?? 'N/A',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Neumorphic container for Logout
            GestureDetector(
              onTap: logout,
              child: NeumorphicContainer(
                child: Center(
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Neumorphic Container Widget
class NeumorphicContainer extends StatelessWidget {
  final Widget child;

  const NeumorphicContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
