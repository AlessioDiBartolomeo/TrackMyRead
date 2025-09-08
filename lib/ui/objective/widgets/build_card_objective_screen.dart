import 'package:flutter/material.dart';

Widget buildCardObjectiveScreen(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple.shade50,
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }