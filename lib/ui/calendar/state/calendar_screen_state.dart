import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/calendar/widgets/calendar_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/models/book.dart';
import 'package:flutter/material.dart';


class CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = true;

  final BookRepository _bookRepository = BookRepository();

  List<Book> allBooks = [];
  Map<DateTime, List<Map<String, dynamic>>> calendarData = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookRepository.loadBooks();
      allBooks = books;

      // Build calendarData
      calendarData.clear();
      for (var book in allBooks) {
        book.readHistory.forEach((dateString, pagesRead) {
          final date = DateTime.parse(dateString);
          final dateKey = DateTime(date.year, date.month, date.day);
          calendarData.putIfAbsent(dateKey, () => []);
          calendarData[dateKey]!.add({'book': book, 'pagesRead': pagesRead});
        });
      }
    } catch (e) {
      debugPrint("Error loading books for calendar: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return calendarData[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              BackButton(color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              Expanded(
                child: Text(
                  "Calendario",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        body: Column(
          children: [
            TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox();
                  return const Icon(Icons.book, size: 20, color: Colors.deepPurple);
                },
              ),
            ),
            const SizedBox(height: 35),
            Expanded(
              child: ListView(
                children: _getEventsForDay(_selectedDay ?? _focusedDay).map((entry) {
                  final book = entry['book'] as Book;
                  final pagesRead = entry['pagesRead'] as int;

                  return GestureDetector(
                    onTap: () async {
                      final shouldRefresh = await Navigator.pushNamed(
                        context,
                        AppRoutes.bookDetail,
                      );
                      if (shouldRefresh != null){
                        _loadBooks();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Taller, narrow image
                          Container(
                            width: 70,
                            height: 120, // taller
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book.imagePath.isNotEmpty
                                  ? (book.imagePath.startsWith('http')
                                      ? Image.network(
                                          book.imagePath,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.asset(
                                          book.imagePath,
                                          fit: BoxFit.fill,
                                        ))
                                  : const Icon(Icons.book, size: 50, color: Colors.deepPurple),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Book info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.bookName,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text("$pagesRead pagine lette",
                                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}