import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/ui/book_detail/widgets/book_detail_screen.dart';
import 'package:flutter_library_app/ui/book_detail/widgets/build_book_image.dart';
import '../widgets/progress_bar.dart';
import '../widgets/update_button.dart';
import '../widgets/update_page.dart';

class BookDetailScreenState extends State<BookDetailScreen> {
  late int currentPage;
  Uint8List? _imageBytes;
  bool isLoading = false;
  final BookRepository _bookRepository = BookRepository();

  @override
  void initState() {
    super.initState();
    currentPage = widget.entry.currentPage;
    _loadImage();
  }

 Future<void> _loadImage() async {
    try {
      final imageBytes = await _bookRepository.loadBookImage(widget.entry.imagePath);
      setState(() {
        _imageBytes = imageBytes;
      });
    } catch (e) {
      debugPrint("Error loading image: $e");
    }
  }

  Future<void> _startReading() async {
    setState(() => isLoading = true);

    try {
      await _bookRepository.startReading(widget.entry);
      setState(() {
        widget.entry.status = 'reading';
        widget.entry.currentPage = 0;
        currentPage = 0;
        widget.entry.startDate = DateTime.now();
        widget.entry.lastReadDate = DateTime.now();
      });
    } catch (e) {
      debugPrint("Error starting reading: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCurrentPage(int newPage) async {
    setState(() => isLoading = true);

    try {
      await _bookRepository.updateCurrentPage(widget.entry, newPage);
      setState(() {
        currentPage = newPage;
        widget.entry.currentPage = newPage;
        widget.entry.status = 'reading';
        widget.entry.lastReadDate = DateTime.now();
      });
    } catch (e) {
      debugPrint("Error updating current page: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _restartBook() async {
    setState(() => isLoading = true);

    try {
      await _bookRepository.restartBook(widget.entry);
      setState(() {
        widget.entry.status = 'reading';
        widget.entry.currentPage = 0;
        currentPage = 0;
        widget.entry.startDate = DateTime.now();
      });
    } catch (e) {
      debugPrint("Error restarting book: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.entry.totalPages > 0 ? currentPage / widget.entry.totalPages : 0.0;
    final daysPassed = widget.entry.startDate != null
        ? DateTime.now().difference(widget.entry.startDate!).inDays
        : null;

    return PopScope <bool>(
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
                  widget.entry.bookName,
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFEDE7F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Book cover
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: buildBookImage(_imageBytes, widget),
                  ),
                ),
                const SizedBox(height: 24),

                // Book Info
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📖 Informazioni",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 12),
                Text(widget.entry.bookName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Center(
                child: Text("Autore/i: ${widget.entry.authorName.join(", ")}",
                    style: const TextStyle(
                        fontSize: 18, fontStyle: FontStyle.italic)),
                ),
                Center(
                  child: Text(
                    widget.entry.genres.isNotEmpty
                        ? "Genere/i: ${widget.entry.genres.join(", ")}"
                        : "",
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.deepPurple),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    widget.entry.genres.isNotEmpty
                        ? "Casa Editrice: ${widget.entry.publisher}": "",
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Text("ISBN: ${widget.entry.isbn}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                if ((widget.entry.readCount) > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    "📚 Letto ${widget.entry.readCount} volte",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 20),

                // Progress
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📊 Progresso",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Pagina $currentPage di ${widget.entry.totalPages}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ProgressBar(progress: progress),
                const SizedBox(height: 20),

                // Update / Start Reading / Restart Button
                UpdateButton(
                  text: widget.entry.status == 'not read'
                      ? "Inizia a Leggere"
                      : widget.entry.status == 'read'
                          ? "Leggi Ancora"
                          : "Aggiorna Pagine Lette",
                  onTap: () async {
                    if (widget.entry.status == 'not read') {
                      _startReading();
                    } else if (widget.entry.status == 'read') {
                      _restartBook();
                    } else {
                      final result = await showModalBottomSheet<int>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => UpdatePage(
                          currentPage: currentPage,
                          totalPages: widget.entry.totalPages,
                          onPageUpdated: (newPage) {
                            _updateCurrentPage(newPage);
                          },
                        ),
                      );
                      if (result != null) _updateCurrentPage(result);
                    }
                  },
                ),
                const SizedBox(height: 30),

                // Started Reading info
                if (widget.entry.startDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Inizio Lettura",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                                "${widget.entry.startDate!.day}/${widget.entry.startDate!.month}/${widget.entry.startDate!.year}",
                                style: const TextStyle(fontSize: 16)),
                            if (daysPassed != null)
                              Text("$daysPassed giorno/i passati",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Description
                if (widget.entry.description != null &&
                    widget.entry.description!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("📝 Descrizione",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      const SizedBox(height: 12),
                      Text(widget.entry.description!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
