import 'package:flutter/material.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/domain/models/book.dart';
import 'package:flutter_library_app/ui/book_detail/widgets/book_detail_screen.dart';
import 'package:flutter_library_app/ui/currently_reading/widgets/currently_reading_screen.dart';

class CurrentlyReadingScreenState extends State<CurrentlyReadingScreen> {
  List<Book> readingBooks = [];
  bool isLoading = true;
  final BookRepository _bookRepository = BookRepository();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);

    try {
      final books = await _bookRepository.loadReadingBooks();
      setState(() {
        readingBooks = books;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading books: $e");
      setState(() => isLoading = false);
    }
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
              BackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const Expanded(
                child: Text(
                  "Libri in Lettura",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: readingBooks.length,
          itemBuilder: (context, index) {
            final entry = readingBooks[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: entry.imagePath.startsWith("assets/")
                    ? Image.asset(entry.imagePath,
                        width: 50, height: 70, fit: BoxFit.cover)
                    : Image.network(entry.imagePath,
                        width: 50, height: 70, fit: BoxFit.cover),
              ),
              title: Text(entry.bookName),
              subtitle: Text("${entry.currentPage}/${entry.totalPages} pagine lette"),
              onTap: () async {
                final shouldRefresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(entry: entry),
                  ),
                );
                if (shouldRefresh == true) {
                  _loadBooks(); // refresh after returning
                }
              },
            );
          },
        ),
      ),
    );
  }
}
