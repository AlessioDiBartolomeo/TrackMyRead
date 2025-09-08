import 'package:hive/hive.dart';

part 'book.g.dart'; // Hive will generate this

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String bookName;

  @HiveField(1)
  final List<String> authorName;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String isbn;

  @HiveField(4)
  int currentPage;

  @HiveField(5)
  final int totalPages;

  @HiveField(6)
  DateTime? startDate;

  @HiveField(7)
  final String imagePath;

  @HiveField(8)
  String status;

  @HiveField(9)
  DateTime? lastReadDate;
  
  @HiveField(10)
  DateTime? endDate;

  @HiveField(11)
  int readCount;

  @HiveField(12)
  final Map<String, int> readHistory;

  @HiveField(13)
  final List<String> genres;

  @HiveField(14)
  final String publisher;

  Book({
    required this.bookName,
    required this.authorName,
    required this.isbn,
    this.description,
    required this.currentPage,
    required this.totalPages,
    this.startDate,
    required this.imagePath,
    required this.status,
    this.lastReadDate,
    this.endDate,
    required this.readCount,
    Map<String, int>? readHistory,
    required this.genres,
    required this.publisher,
  }) : readHistory = readHistory ?? {};
}
