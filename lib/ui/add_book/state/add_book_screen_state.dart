import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/data/services/book_service.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/add_book/widgets/add_book_button.dart';
import 'package:flutter_library_app/ui/add_book/widgets/add_book_screen.dart';
import 'package:flutter_library_app/ui/add_book/widgets/barcode_scanner_screen.dart';
import 'package:flutter_library_app/ui/add_book/widgets/book_description_text_field.dart';
import 'package:flutter_library_app/ui/add_book/widgets/book_pages_field.dart';
import 'package:flutter_library_app/ui/core/ui/my_bottom_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/ui/custom_text_field.dart';
import '../../../domain/models/book.dart';

class AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  File? _pickedImage;
  String? _coverUrl;

  final BookRepository _bookRepository = BookRepository();

  int _selectedIndex = 1;

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _authorController.text.isNotEmpty &&
      _pagesController.text.isNotEmpty &&
      _isbnController.text.isNotEmpty &&
      _genresController.text.isNotEmpty;
  
  TextEditingController get nameController => _nameController;
  TextEditingController get authorController => _authorController;
  TextEditingController get isbnController => _isbnController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get pagesController => _pagesController;
  TextEditingController get genresController => _genresController;
  TextEditingController get publisherController => _publisherController;
  bool get isFormValid => _isFormValid;

  void _onNavTap(int index) {
    setState((){
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          AppRoutes.home,
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.account,
        );
        break;
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galleria"),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null && mounted) {
                  setState(() {
                    _pickedImage = File(pickedFile.path);
                    _coverUrl = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Fotocamera"),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null && mounted) {
                  setState(() {
                    _pickedImage = File(pickedFile.path);
                    _coverUrl = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final scannedIsbn = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedIsbn != null && mounted) {
      _isbnController.text = scannedIsbn;
      _fetchBookFromISBN(scannedIsbn);
    }
  }

  Future<void> _fetchBookFromISBN(String isbn) async {
    try {
      final book = await BookService.fetchBookByISBN(isbn);
      if (book == null) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Errore"),
            content: const Text(
                "Impossibile trovare il libro tramite i servizi disponibili."),
            actions: [
              TextButton(
                onPressed: () {
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _nameController.text = book.title;
        _authorController.text = book.authors?.join(", ") ?? "";
        _descriptionController.text = book.description ?? "";
        _pagesController.text = book.pageCount?.toString() ?? "";
        _coverUrl = book.thumbnail; // may be null
        _pickedImage = null;
        _genresController.text = book.genres?.join(", ") ?? "";
        _publisherController.text = book.publisher ?? "";
      });
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Errore"),
          content: Text("Errore durante il recupero dei dati: $e"),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final fixedUrl = url.replaceFirst("http:", "https:");
      final response = await http.get(Uri.parse(fixedUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint("Error fetching image: $e");
    }
    return null;
  }

  Future<void> _saveBook() async {
    if (!Hive.isBoxOpen('books')) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      await Hive.openBox<Book>('books');
    }
    Hive.box<Book>('books');

    final newBook = Book(
      bookName: _nameController.text,
      authorName: _authorController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(),
      genres: _genresController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(), 
      isbn: _isbnController.text,
      status: "not read",
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      currentPage: 0,
      startDate: null,
      description: _descriptionController.text,
      imagePath: _coverUrl ?? "", // empty string if no URL
      lastReadDate: null,
      endDate: null,
      readCount: 0,
      publisher: _publisherController.text,
    );

    try {
      await _bookRepository.saveBookToLocalStorage(newBook);
      await _bookRepository.saveBookToFirestore(newBook);
    } catch (e) {
      print(e);
    }

    if (mounted) Navigator.pop(context, newBook);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _authorController.addListener(_onFieldChanged);
    _pagesController.addListener(_onFieldChanged);
    _isbnController.addListener(_onFieldChanged);
    _genresController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _pagesController.dispose();
    _genresController.dispose();
    _publisherController.dispose();
    if (widget.onTabChanged != null) widget.onTabChanged!(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Center(
                child: Text(
                  "Aggiungi Libro",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withAlpha(50),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_pickedImage!,
                                    width: 80, height: 120, fit: BoxFit.cover),
                              )
                            : (_coverUrl != null && _coverUrl!.isNotEmpty)
                                ? FutureBuilder<Uint8List?>(
                                    future: _fetchImageBytes(_coverUrl!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.deepPurple,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.memory(
                                            snapshot.data!,
                                            width: 80,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return const Icon(Icons.broken_image,
                                          size: 48, color: Colors.deepPurple);
                                    },
                                  )
                                : const Icon(Icons.image,
                                    size: 48, color: Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scannerizza ISBN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                        controller: _nameController,
                        label: "Nome Libro",
                        required: true),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _authorController,
                        label: "Autori (separati da virgola, es. Mario Rossi, Luigi Bianchi)",
                        required: true),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _genresController,
                        label: "Generi (separati da virgola, es. Fantascienza, Romanzo)",
                        required: true),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _publisherController,
                        label: "Casa Editrice",
                        required: true),
                    const SizedBox(height: 16),
                    BookDescriptionTextField(
                        controller: _descriptionController, label: "Descrizione"),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _isbnController,
                      label: "ISBN",
                      required: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.deepPurple),
                        onPressed: () {
                          if (_isbnController.text.isNotEmpty) {
                            _fetchBookFromISBN(_isbnController.text);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    BookPagesField(controller: _pagesController),
                    const SizedBox(height: 30),
                    AddBookButton(
                      enabled: _isFormValid,
                      onTap: _isFormValid ? _saveBook : null,
                    ),
                  ],
                ),
              ),
            ),
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