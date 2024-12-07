import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final TextEditingController emailController;
  final ValueNotifier<String> usernameNotifier;

  ProfilePage({
    required TextEditingController usernameController,
    required this.emailController,
    required String userId,
  }) : usernameNotifier = ValueNotifier<String>(usernameController.text);

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
              offset: Offset(4, 4),
              blurRadius: 6,
            ),
            BoxShadow(
              color: highlightColor,
              offset: Offset(-4, -4),
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
                  // Update the username value
                  usernameNotifier.value = editController.text;
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Username updated successfully!")),
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
            mainAxisSize: MainAxisSize.min, // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Username label

              // Username field with edit option
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

              // Email label

              // Email field with neumorphic design
              neumorphicContainer(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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

              // Save button with neumorphic design
              SizedBox(
                width: double.infinity,
                child: neumorphicContainer(
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profile saved successfully!")),
                      );
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
