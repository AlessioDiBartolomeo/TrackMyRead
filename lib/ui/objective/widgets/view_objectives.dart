import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_library_app/ui/objective/widgets/build_card_view_objectives.dart';
import 'package:intl/date_symbol_data_local.dart';

class ViewObjectives extends StatefulWidget {
  const ViewObjectives({super.key});

  @override
  State<ViewObjectives> createState() => _ViewObjectivesScreenState();
}

class _ViewObjectivesScreenState extends State<ViewObjectives> {
  bool isLoading = true;
  Map<String, int> objectives = {"daily": 0, "monthly": 0, "yearly": 0};
  Map<String, int> progress = {"daily": 0, "monthly": 0, "yearly": 0};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null).then((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 🔹 Carica obiettivi
    final objDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('objectives')
        .doc('reading')
        .get();

    if (objDoc.exists) {
      final data = objDoc.data()!;
      objectives = {
        "daily": data['daily'] ?? 0,
        "monthly": data['monthly'] ?? 0,
        "yearly": data['yearly'] ?? 0,
      };
    }

    // 🔹 Calcola progresso da pagesRead
    final now = DateTime.now();
    int daily = 0, monthly = 0, yearly = 0;

    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      final Map<String, dynamic>? pagesRead =
          (data['pagesRead'] as Map<String, dynamic>?);

      if (pagesRead != null) {
        for (var entry in pagesRead.entries) {
          final date = DateTime.tryParse(entry.key);
          final pages = entry.value as int;

          if (date != null) {
            if (date.year == now.year) yearly += pages;
            if (date.year == now.year && date.month == now.month) monthly += pages;
            if (date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) {
              daily += pages;
            }
          }
        }
      }
    }

    setState(() {
      progress = {"daily": daily, "monthly": monthly, "yearly": yearly};
      isLoading = false;
    });
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
        title: const Text("Obiettivi Lettura"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCardViewObjectives("📅 Oggi", progress["daily"]!, objectives["daily"]!),
          const SizedBox(height: 12),
          buildCardViewObjectives("🗓️ Questo mese", progress["monthly"]!, objectives["monthly"]!),
          const SizedBox(height: 12),
          buildCardViewObjectives("📆 Quest'anno", progress["yearly"]!, objectives["yearly"]!),
        ],
      ),
    );
  }
}
