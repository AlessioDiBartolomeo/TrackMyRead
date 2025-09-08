import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsChart extends StatelessWidget {
  final String title;
  final Map<String, int> data;

  const StatisticsChart({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: Text("Nessun dato disponibile")),
      );
    }

    // Sort by value (descending)
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Keep top 5, group the rest into "Altri"
    final topEntries = sortedEntries.take(5).toList();
    final othersCount = sortedEntries.skip(5).fold<int>(0, (sum, e) => sum + e.value);
    if (othersCount > 0) {
      topEntries.add(MapEntry("Altri", othersCount));
    }

    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pie Chart
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildPieSections(topEntries, total),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of all entries
            Expanded(
              child: ListView(
                children: sortedEntries.map((entry) {
                  final percent = (entry.value / total * 100).toStringAsFixed(1);
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text("${entry.value} ($percent%)"),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<MapEntry<String, int>> entries, int total) {
    final colors = [
      Colors.deepPurple,
      Colors.purple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.grey, // for "Altri"
    ];

    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final value = entry.value.toDouble();
      final percent = (value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: "${entry.key}\n$percent%",
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    });
  }
}
