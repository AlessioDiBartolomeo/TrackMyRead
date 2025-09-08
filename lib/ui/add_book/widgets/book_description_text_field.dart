import 'package:flutter/material.dart';

class BookDescriptionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const BookDescriptionTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80,  // Minimum height of the box
        maxHeight: 200, // Maximum height of the box
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: 3, // initial lines
        maxLines: null, // allow dynamic growth
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
