class CalendarReadingEntry {
  final String bookName;
  final DateTime date;
  final int pagesRead;
  final String? imagePath;

  CalendarReadingEntry({
    required this.bookName,
    required this.date,
    required this.pagesRead,
    this.imagePath,
  });
}
