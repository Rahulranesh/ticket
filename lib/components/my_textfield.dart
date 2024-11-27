import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon; // Add suffixIcon parameter

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.suffixIcon,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjust padding
      child: MouseRegion(
        onEnter: (_) => _setHovered(true), // Handle hover enter
        onExit: (_) => _setHovered(false), // Handle hover exit
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          cursorColor: Theme.of(context).colorScheme.primary, // Cursor color
          style: const TextStyle(
            color: Colors.black, // Text color inside the field
          ),
          decoration: InputDecoration(
            filled: true, // Enables fill color
            fillColor: _isHovered
                ? Colors.white
                : Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(0.1), // Background color on hover
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black, // Border color when not focused
              ),
              borderRadius: BorderRadius.circular(20), // More circular border
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Border color when focused
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(20), // More circular border
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.grey), // Hint text color
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10, // Inner padding
            ),
            suffixIcon: widget.suffixIcon, // Add suffixIcon here
          ),
        ),
      ),
    );
  }

  // Helper function to update hover state
  void _setHovered(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
  }
}
