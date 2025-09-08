import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final BorderRadius? borderRadius;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      child: Stack(
        alignment: Alignment.center, // centers the percentage text
        children: [
          // Background bar
          Container(
            height: height,
            color: Colors.grey[300],
          ),
          // Foreground gradient bar, aligned to left
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          // Percentage text vertically centered
          Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
