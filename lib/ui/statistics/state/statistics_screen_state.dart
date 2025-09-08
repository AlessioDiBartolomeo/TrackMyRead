import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_library_app/data/repositories/statistics_repository.dart';
import 'package:flutter_library_app/ui/statistics/widgets/build_card.dart';
import 'package:flutter_library_app/ui/statistics/widgets/statistics_chart.dart';
import 'package:flutter_library_app/ui/statistics/widgets/statistics_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> booksPerAuthor = {};
  Map<String, int> booksPerPublisher = {};
  Map<String, int> booksPerGenre = {};
  Map<int, int> booksPerMonth = {};
  bool isLoading = true;
  final StatisticsRepository _statisticsRepository = StatisticsRepository();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null).then((_) {
      _fetchStatistics();
    });
  }

  Future<void> _fetchStatistics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    try {
      final authors = await _statisticsRepository.getBooksPerAuthor(uid);
      final publishers = await _statisticsRepository.getBooksPerPublisher(uid);
      final genres = await _statisticsRepository.getBooksPerGenre(uid);
      final months = await _statisticsRepository.getBooksPerMonth(uid);

      setState(() {
        booksPerAuthor = authors;
        booksPerPublisher = publishers;
        booksPerGenre = genres;
        booksPerMonth = months;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching statistics: $e");
    }
  }

  void _openChartPage(String title, Map<String, int> data) {
    final filteredData = Map<String, int>.from(data);

    if (title.contains("casa editrice")) {
    filteredData.remove("Casa editrice non disponibile");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsChart(title: title, data: filteredData),
      ),
    );
  }

  void _openMonthChart() {
    final monthNames = List.generate(12, (i) {
      return DateFormat.MMMM('it_IT').format(DateTime(0, i + 1));
    });

    final monthData = {
      for (var entry in booksPerMonth.entries)
        monthNames[entry.key - 1]: entry.value
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsChart(
          title: "📅 Libri per mese",
          data: monthData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiche Letture"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCard("📚 Libri per autore", booksPerAuthor, () {
            _openChartPage("📚 Libri per autore", booksPerAuthor);
          }),
          const SizedBox(height: 12),
          buildCard("🏢 Libri per casa editrice", booksPerPublisher, () {
            _openChartPage("🏢 Libri per casa editrice", booksPerPublisher);
          }),
          const SizedBox(height: 12),
          buildCard("🎭 Libri per genere", booksPerGenre, () {
            _openChartPage("🎭 Libri per genere", booksPerGenre);
          }),
          const SizedBox(height: 12),
          buildCard("📅 Libri per mese", booksPerMonth.map(
            (k, v) => MapEntry(
              DateFormat.MMMM('it_IT').format(DateTime(0, k)),
              v,
            ),
          ), _openMonthChart),
        ],
      ),
    );
  }
}
