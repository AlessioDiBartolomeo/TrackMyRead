import 'dart:io';
import 'package:flutter/material.dart';

Widget buildBookImage(imageBytes, widget) {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        width: 160,
        height: 240,
        fit: BoxFit.cover,
      );
    } else if (widget.entry.imagePath.startsWith('assets/')) {
      return Image.asset(
        widget.entry.imagePath,
        width: 160,
        height: 240,
        fit: BoxFit.cover,
      );
    } else if (File(widget.entry.imagePath).existsSync()) {
      return Image.file(
        File(widget.entry.imagePath),
        width: 160,
        height: 240,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.book, size: 160, color: Colors.deepPurple);
    }
  }