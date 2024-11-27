import 'package:flutter/material.dart';
import 'package:ticket/components/my_button.dart';
import 'package:ticket/components/my_textfield.dart';

import 'package:ticket/services/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool checkbox = false;
  String selectedRole = 'User';
  bool showPassword = false;

  final List<String> roles = ['User', 'Organizer', 'Admin'];
  final ApiService _apiService = ApiService();

  final Color navbarColor = const Color.fromARGB(255, 8, 5, 61);

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onSubmit() async {
    if (!checkbox) {
      _showErrorDialog("Please accept the terms and conditions");
      return;
    } else if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        (selectedRole != 'Organizer' &&
            (firstNameController.text.isEmpty ||
                lastNameController.text.isEmpty)) ||
        (selectedRole == 'Organizer' && nameController.text.isEmpty)) {
      _showErrorDialog("Please fill all the fields");
      return;
    }

    try {
      final response = await _apiService.register(
        firstNameController.text,
        lastNameController.text,
        usernameController.text,
        emailController.text,
        passwordController.text,
        selectedRole,
        name: selectedRole == 'Organizer' ? nameController.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _onRoleChanged(String? newValue) {
    setState(() {
      selectedRole = newValue!;
      if (selectedRole == 'Organizer') {
        firstNameController.clear();
        lastNameController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: navbarColor,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 80,
                width: double.infinity,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12)
            .copyWith(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Text(
              'Create an Account',
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: navbarColor),
            ),
            SizedBox(height: 5),
            Text(
              'Make your events visible by ticketverse',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: _onRoleChanged,
                decoration: InputDecoration(
                  hintText: 'Select Role',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            if (selectedRole == 'Organizer')
              Column(
                children: [
                  MyTextField(
                    controller: nameController,
                    hintText: "Organization Name",
                    obscureText: false,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            if (selectedRole != 'Organizer') ...[
              MyTextField(
                controller: firstNameController,
                hintText: "First Name",
                obscureText: false,
              ),
              SizedBox(height: 16),
              MyTextField(
                controller: lastNameController,
                hintText: "Last Name",
                obscureText: false,
              ),
              SizedBox(height: 16),
            ],
            MyTextField(
              controller: usernameController,
              hintText: "Username",
              obscureText: false,
            ),
            SizedBox(height: 16),
            MyTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            SizedBox(height: 16),
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: !showPassword,
              suffixIcon: GestureDetector(
                onTap: togglePasswordVisibility,
                child: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Checkbox(
                    value: checkbox,
                    onChanged: (value) {
                      setState(() {
                        checkbox = value!;
                      });
                    },
                  ),
                ),
                Text('I agree to terms & Policy.'),
              ],
            ),
            SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                onTap: onSubmit,
                text: "Register",
                color: navbarColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
