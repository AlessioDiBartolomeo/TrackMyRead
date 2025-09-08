import 'package:flutter/material.dart';

class BooksReadChart extends StatelessWidget {
  final List<int> data; // 12 months of books read

  const BooksReadChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(data.length, (index) {
        final monthValue = data[index];
        final barHeight = maxValue > 0 ? (monthValue / maxValue) * 150.0 : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            Container(
              width: 18,
              height: barHeight.toDouble(),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6), // space between bar and number
            // Number of books
            Text(
              '$monthValue',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4), // space to month label
            // Month label
            Text(
              _monthAbbr(index),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      }),
    );
  }

  String _monthAbbr(int index) {
    const months = [
      'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
      'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'
    ];
    return months[index];
  }
}
