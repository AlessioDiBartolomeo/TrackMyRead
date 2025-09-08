import 'package:flutter/material.dart';

Widget buildCard(String title, Map<String, int> data, VoidCallback onTap) {
    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple.shade50,
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        subtitle: Text("Totale: $total"),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }