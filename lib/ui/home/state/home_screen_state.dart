import 'package:flutter/material.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/home/widgets/books_read_chart.dart';
import 'package:flutter_library_app/ui/home/widgets/home_screen.dart';
import 'package:flutter_library_app/ui/core/ui/my_bottom_navigation_bar.dart';
import '../../../domain/models/book.dart';
import '../../book_detail/widgets/book_detail_screen.dart';
import '../../core/ui/stat_card.dart';
import '../../core/ui/action_button.dart';

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Book> readingBooks = [];
  List<Book> latestBooks = [];
  List<Book> readBooks = [];
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
      final books = await _bookRepository.loadBooks();

      readingBooks = books.where((b) => b.status == "reading").toList()
        ..sort((a, b) =>
            b.lastReadDate?.compareTo(a.lastReadDate ?? DateTime(0)) ?? 0);

      readBooks = books.where((b) => b.readCount > 0).toList()
        ..sort((a, b) =>
            b.endDate?.compareTo(a.endDate ?? DateTime(0)) ?? 0);

      latestBooks = readingBooks.take(4).toList();
    } catch (e) {
      debugPrint("Error loading books: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _onNavTap(int index) {
    setState((){
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(
          context,
          AppRoutes.addBook,
        );
        break;
      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.account,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Header with stats
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bentornato/a!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: "Libri Letti",
                            value: readBooks.fold<int>(0, (sum, book) => sum + book.readCount),
                            icon: Icons.book,
                            color: Colors.white,
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: "Pagine Lette",
                            value: readBooks.fold(
                                0, (total, b) => total + b.totalPages),
                            icon: Icons.menu_book,
                            color: Colors.white,
                            backgroundColor: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Books Read Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progresso di Lettura (Gen – Dic)",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BooksReadChart(
                          data: List.generate(12, (monthIndex) {
                            final month = monthIndex + 1;
                            return readBooks.fold<int>(0, (acc, b) {
                              // Sum the readCount for each book for the current month
                              return acc + b.readHistory.entries
                                .where((entry) {
                                  final date = DateTime.parse(entry.key);
                                  return date.month == month;
                                })
                                .fold<int>(0, (total, entry) => total + b.readCount); // Add readCount for each book
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Latest reading books carousel
            if (latestBooks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Ultimi Libri in Lettura",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: latestBooks.length,
                  itemBuilder: (context, index) {
                    final entry = latestBooks[index];
                    return GestureDetector(
                      onTap: () async {
                        final shouldRefresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(entry: entry),
                          ),
                        );

                        if (shouldRefresh == true) {
                          _loadBooks();
                        }
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: entry.imagePath.startsWith("assets/")
                                ? AssetImage(entry.imagePath)
                                : NetworkImage(entry.imagePath)
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[300],
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Libri in Lettura Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () async {
                  final shouldRefresh = await Navigator.pushNamed(
                    context,
                    AppRoutes.currentlyReading,
                  );

                  if (shouldRefresh == true) {
                    _loadBooks();
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book,
                            size: 40, color: Colors.deepPurple),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Libri in Lettura",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${readingBooks.length} libri in lettura",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Azioni Rapide",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ActionButton(
                        icon: Icons.library_books,
                        label: "La Mia Libreria",
                        onTap: () async {
                          final shouldRefresh = await Navigator.pushNamed(
                            context,
                            AppRoutes.library,
                          );

                          if (shouldRefresh == true) {
                            _loadBooks();
                          }
                        },
                      ),
                      ActionButton(
                        icon: Icons.bar_chart,
                        label: "Statistiche",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.statistics,
                          );
                        },
                      ),
                      ActionButton(
                        icon: Icons.calendar_today,
                        label: "Calendario",
                        onTap: () async {
                          final shouldRefresh = await Navigator.pushNamed(
                            context,
                            AppRoutes.calendar,
                          );
                          if (shouldRefresh == true) {
                            _loadBooks();
                          }
                        },
                      ),
                      ActionButton(
                        icon: Icons.checklist,
                        label: "Obiettivi",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.objective,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
