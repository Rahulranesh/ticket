import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart'; // Import this to use Navigator

class ProfilePage extends StatelessWidget {
  final TextEditingController emailController;
  final ValueNotifier<String> usernameNotifier;

  ProfilePage({
    required TextEditingController usernameController,
    required this.emailController,
    required String userId,
  }) : usernameNotifier = ValueNotifier<String>(usernameController.text);

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String apiUrl = "https://api.ticketverz.com/api/auth/customer";

  Future<void> updateProfile(BuildContext context) async {
    try {
      final cookie = await secureStorage.read(key: "Attendee-Signature");
      if (cookie == null) {
        throw Exception("Authentication cookie not found. Please log in again.");
      }

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "Attendee-Signature=$cookie", // Include the cookie in the headers
        },
        body: jsonEncode({
          "username": usernameNotifier.value,
          "email": emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody["message"] ?? "Profile updated successfully!")),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse["message"] ?? "Failed to update profile.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  // Function to log out and clear cookies
  Future<void> logout(BuildContext context) async {
    try {
      await secureStorage.deleteAll(); // Clears all stored cookies
      Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF2F2F2);
    final Color shadowColor = Colors.grey.shade300;
    final Color highlightColor = Colors.white;

    Widget neumorphicContainer(Widget child) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 6,
            ),
            BoxShadow(
              color: highlightColor,
              offset: const Offset(-4, -4),
              blurRadius: 6,
            ),
          ],
        ),
        child: child,
      );
    }

    void showEditDialog(BuildContext context) {
      final TextEditingController editController =
          TextEditingController(text: usernameNotifier.value);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit Username"),
            content: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: "Enter new username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  usernameNotifier.value = editController.text;
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Username updated successfully!")),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 5, 61),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Username field
              ValueListenableBuilder<String>(
                valueListenable: usernameNotifier,
                builder: (context, username, _) {
                  return neumorphicContainer(
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: username),
                              decoration: InputDecoration(
                                hintText: 'Username',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.person,
                                    color: Colors.grey.shade600),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showEditDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Email field
              neumorphicContainer(
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                      prefixIcon:
                          Icon(Icons.email, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),

              // Save Changes button
              SizedBox(
                width: double.infinity,
                child: neumorphicContainer(
                  TextButton(
                    onPressed: () => updateProfile(context),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: neumorphicContainer(
                  TextButton(
                    onPressed: () => logout(context),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
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
      ),
    );
  }
}
