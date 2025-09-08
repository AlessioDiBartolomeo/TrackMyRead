import 'package:flutter/material.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/ui/library/widgets/library_screen.dart';
import '../../../domain/models/book.dart';
import '../../book_detail/widgets/book_detail_screen.dart';

class LibraryScreenState extends State<LibraryScreen> {
  List<Book> allBooks = [];
  bool isLoading = true;
  final BookRepository _bookRepository = BookRepository();
  

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final books = await _bookRepository.loadBooks();
      setState(() {
        allBooks = books;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading books: $e");
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'read':
        return Icons.check_circle;
      case 'reading':
        return Icons.menu_book;
      default:
        return Icons.book_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'read':
        return Colors.green.withOpacity(0.8);
      case 'reading':
        return Colors.orange.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.8);
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
              BackButton(color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              Expanded(
                child: Text(
                  "Libreria",
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
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2/4, // width:height ~3:5
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: allBooks.length,
          itemBuilder: (context, index) {
            final book = allBooks[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(entry: book),
                  ),
                );
              },
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover container
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: book.imagePath.isNotEmpty
                                ? (book.imagePath.startsWith("assets/")
                                    ? Image.asset(
                                        book.imagePath,
                                        fit: BoxFit.fill, // fill the container
                                      )
                                    : Image.network(
                                        book.imagePath,
                                        fit: BoxFit.fill, // fill the container
                                      ))
                                : const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Book title
                      Text(
                        book.bookName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      // Author
                      Text(
                        book.authorName.join(", "),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Status icon overlay on cover
                  Positioned(
                    bottom: 60, // inside the cover
                    left: 4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.deepPurple.withOpacity(0.6),
                      child: Icon(
                        _statusIcon(book.status),
                        color: _statusColor(book.status),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
