import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon; // <-- added

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon, // <-- added
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: suffixIcon, // <-- added
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return "Campo obbligatorio";
        }
        if (keyboardType == TextInputType.number && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return "Deve essere un numero";
          }
        }
        return null;
      },
    );
  }
}
