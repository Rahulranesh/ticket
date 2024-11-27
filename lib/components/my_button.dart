import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final Function()? onTap;
  final String text;
  final Color color; // Button color

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10.0), 
          margin: EdgeInsets.all(15),// Similar height as text fields
       // Match text field margin
          width: double.infinity, // Take full available width
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withOpacity(0.8)
                : widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(-3, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setHovered(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
  }
}
