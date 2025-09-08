import 'package:flutter/material.dart';


Widget buildCardViewObjectives(String title, int current, int target,) {
  
  String motivationalPhrase(int current, int target) {
    if (current == 0) return "Inizia a leggere per raggiungere il tuo obiettivo!";
    if (current < target * 0.5) return "Il tuo viaggio è ancora lungo!";
    if (current < target) return "Ci sei quasi, continua così!";
    return "Obiettivo raggiunto 🎉";
  }
    final phrase = motivationalPhrase(current, target);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple.shade50,
      child: ListTile(
        title: Text("$title: $current / $target pagine",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        subtitle: Text(phrase),
      ),
    );
  }