import 'package:flutter/material.dart';

class BookPagesField extends StatelessWidget {
  final TextEditingController controller;

  const BookPagesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Numero di pagine",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obbligatorio";
        }
        final intValue = int.tryParse(value);
        if (intValue == null) {
          return "Deve essere un numero intero";
        }
        if (intValue <= 0) {
          return "Deve essere maggiore di zero";
        }
        return null;
      },
    );
  }
}
