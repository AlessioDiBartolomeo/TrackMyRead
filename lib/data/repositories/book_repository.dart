import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_library_app/data/model/google_book_model.dart';
import 'package:flutter_library_app/data/services/book_service.dart';
import 'package:flutter_library_app/domain/models/book.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BookRepository {
  // Fetch book from external APIs
  Future<GoogleBookModel?> fetchBookFromISBN(String isbn) async {
    try {
      final book = await BookService.fetchBookByISBN(isbn);
      if (book == null) {
        return null;
      }
      return book;
    } catch (e) {
      throw Exception('Failed to fetch book: $e');
    }
  }

  // Save book to local Hive storage
  Future<void> saveBookToLocalStorage(Book book) async {
    if (!Hive.isBoxOpen('books')) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      await Hive.openBox<Book>('books');
    }
    final box = Hive.box<Book>('books');
    await box.add(book);
  }

  // Save book to Firebase Firestore
  Future<void> saveBookToFirestore(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('books')
          .add({
        'bookName': book.bookName,
        'authorName': book.authorName,
        'description': book.description,
        'isbn': book.isbn,
        'status': book.status,
        'totalPages': book.totalPages,
        'currentPage': book.currentPage,
        'startDate': book.startDate?.toIso8601String(),
        'imagePath': book.imagePath,
        'readHistory': {},
        'publisher': book.publisher,
      });
    } catch (e) {
      throw Exception('Failed to save book to Firestore: $e');
    }
  }

  Future<Uint8List?> loadBookImage(String imagePath) async {
    if (imagePath.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } catch (e) {
        throw Exception("Failed to load image: $e");
      }
    }
    return null;
  }

  Future<void> startReading(Book entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final userBooks = FirebaseFirestore.instance.collection('users').doc(uid).collection('books');

    try {
      final query = await userBooks.where('isbn', isEqualTo: entry.isbn).get();
      if (query.docs.isEmpty) throw Exception("Book not found");

      final doc = query.docs.first;
      await doc.reference.update({
        'status': 'reading',
        'startDate': entry.startDate ?? DateTime.now(),
        'currentPage': 0,
        'lastReadDate': DateTime.now(),
      });
    } catch (e) {
      throw Exception("Failed to start reading: $e");
    }
  }

  Future<void> updateCurrentPage(Book entry, int newPage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final userBooks = FirebaseFirestore.instance.collection('users').doc(uid).collection('books');

    try {
      final query = await userBooks.where('isbn', isEqualTo: entry.isbn).get();
      if (query.docs.isEmpty) throw Exception("Book not found");

      final doc = query.docs.first;
      final todayKey = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      if (newPage >= entry.totalPages) {
        // Book completed
        await doc.reference.update({
          'currentPage': entry.totalPages,
          'status': 'read',
          'endDate': DateTime.now(),
          'readCount': FieldValue.increment(1),
          'readHistory': FieldValue.arrayUnion([{'finishedAt': DateTime.now()}]),
          'pagesRead.$todayKey': entry.totalPages,
        });
      } else {
        // Still reading
        await doc.reference.update({
          'currentPage': newPage,
          'status': 'reading',
          'lastReadDate': DateTime.now(),
          'pagesRead.$todayKey': newPage,
        });
      }
    } catch (e) {
      throw Exception("Failed to update current page: $e");
    }
  }

  Future<void> restartBook(Book entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final userBooks = FirebaseFirestore.instance.collection('users').doc(uid).collection('books');

    try {
      final query = await userBooks.where('isbn', isEqualTo: entry.isbn).get();
      if (query.docs.isEmpty) throw Exception("Book not found");

      final doc = query.docs.first;
      await doc.reference.update({
        'status': 'reading',
        'currentPage': 0,
        'startDate': DateTime.now(),
        'lastReadDate': DateTime.now(),
      });
    } catch (e) {
      throw Exception("Failed to restart book reading: $e");
    }
  }

  Future<List<Book>> loadBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Book(
          bookName: data['bookName'] ?? '',
          authorName: (data['authorName'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
          isbn: data['isbn'] ?? '',
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 0,
          publisher: data['publisher'] ?? '',
          description: data['description'],
          imagePath: data['imagePath'] ?? '',
          startDate: data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : null,
          lastReadDate: data['lastReadDate'] != null
              ? (data['lastReadDate'] as Timestamp).toDate()
              : null,
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          status: data['status'] ?? 'not read',
          readCount: data['readCount'] ?? 0,
          readHistory: (data['pagesRead'] as Map<String, dynamic>?)
                  ?.map((key, value) => MapEntry(key, value as int)) ??
              {},
          genres: (data['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
      throw Exception("Failed to load books: $e");
    }
  }

  Future<List<Book>> loadReadingBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    
    final connectivityResult = await Connectivity().checkConnectivity();
    
    try {
      // ignore: unrelated_type_equality_checks
      if (connectivityResult != ConnectivityResult.none) {
        // Fetch from Firestore when online
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('books')
            .where('status', isEqualTo: 'reading')
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Book(
            bookName: data['bookName'] ?? '',
            authorName: (data['authorName'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            isbn: data['isbn'] ?? '',
            totalPages: data['totalPages'] ?? 0,
            currentPage: data['currentPage'] ?? 0,
            publisher: data['publisher'] ?? '',
            description: data['description'],
            imagePath: data['imagePath'] ?? '',
            startDate: data['startDate'] != null
                ? (data['startDate'] as Timestamp).toDate()
                : null,
            lastReadDate: data['lastReadDate'] != null
                ? (data['lastReadDate'] as Timestamp).toDate()
                : null,
            endDate: data['endDate'] != null
                ? (data['endDate'] as Timestamp).toDate()
                : null,
            status: data['status'] ?? 'not read',
            readCount: data['readCount'] ?? 0,
            readHistory: (data['pagesRead'] as Map<String, dynamic>?)
                    ?.map((key, value) => MapEntry(key, value as int)) ??
                {},
            genres: (data['genres'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          );
        }).toList();
      } else {
        // Fetch from Hive when offline
        return [];
      }
    } catch (e) {
      throw Exception("Error loading books: $e");
    }
  }




}
