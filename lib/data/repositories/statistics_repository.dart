import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsRepository {
  Future<Map<String, int>> getBooksPerAuthor(String uid) async {
    final authors = <String, int>{};
    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      final readCount = (data['readCount'] ?? 0) as int;

      if (readCount <= 0) continue;

      final authorList = (data['authorName'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [];
      for (var author in authorList) {
        authors[author] = (authors[author] ?? 0) + 1;
      }
    }
    return authors;
  }

  Future<Map<String, int>> getBooksPerPublisher(String uid) async {
    final publishers = <String, int>{};
    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      final readCount = (data['readCount'] ?? 0) as int;

      if (readCount <= 0) continue;

      final rawPublisher = data['publisher']?.toString().trim();
      if (rawPublisher == null || rawPublisher.isEmpty) {
        publishers["Casa editrice non disponibile"] =
            (publishers["Casa editrice non disponibile"] ?? 0) + 1;
      } else {
        publishers[rawPublisher] = (publishers[rawPublisher] ?? 0) + 1;
      }
    }
    return publishers;
  }

  Future<Map<String, int>> getBooksPerGenre(String uid) async {
    final genres = <String, int>{};
    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      final readCount = (data['readCount'] ?? 0) as int;

      if (readCount <= 0) continue;

      final genreList = (data['genres'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [];
      for (var genre in genreList) {
        genres[genre] = (genres[genre] ?? 0) + 1;
      }
    }
    return genres;
  }

  Future<Map<int, int>> getBooksPerMonth(String uid) async {
    final months = {for (var i = 1; i <= 12; i++) i: 0};
    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .get();

    final now = DateTime.now();
    final currentYear = now.year;

    for (var doc in booksSnapshot.docs) {
      final data = doc.data();
      final readCount = (data['readCount'] ?? 0) as int;

      if (readCount <= 0) continue;

      final endDate = data['endDate'];
      if (endDate != null) {
        DateTime? finished;
        if (endDate is String) {
          finished = DateTime.tryParse(endDate);
        } else if (endDate is Timestamp) {
          finished = endDate.toDate();
        }
        if (finished != null && finished.year == currentYear) {
          months[finished.month] = (months[finished.month] ?? 0) + 1;
        }
      }
    }
    return months;
  }
}
