import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final DateTime? startDate;
  final int daysPassed;

  const InfoCard({super.key, required this.startDate, required this.daysPassed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(103, 58, 183, 0.2),
            offset: const Offset(0, 6),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                "Start Date",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                startDate != null
                    ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
                    : "N/A",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Days Passed",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text("$daysPassed", style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
