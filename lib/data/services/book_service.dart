import 'package:flutter_library_app/data/services/google_book_service.dart';
import 'package:flutter_library_app/data/model/google_book_model.dart';

import 'open_library_service.dart';

class BookService {
  static Future<GoogleBookModel?> fetchBookByISBN(String isbn) async {
    // 1️⃣ Try Google Books first
    final googleBook = await GoogleBooksService.fetchBookByISBN(isbn);
    if (googleBook == null) return null;

    // 2️⃣ If description or pageCount missing, try Open Library
    if ((googleBook.description == null || googleBook.description!.isEmpty || googleBook.description!.compareTo("") == 0) ||
        (googleBook.pageCount == null || googleBook.pageCount == 0)) {
      final openLibBook = await OpenLibraryService.fetchBookByISBN(isbn);
      if (openLibBook != null) {
        final description = googleBook.description?.isNotEmpty == true
            ? googleBook.description
            : openLibBook.description;

        final pageCount = googleBook.pageCount ?? openLibBook.pageCount;

        return GoogleBookModel(
          title: googleBook.title,
          authors: googleBook.authors,
          description: description,
          pageCount: pageCount,
          thumbnail: googleBook.thumbnail,
          genres: googleBook.genres,
          publisher: googleBook.publisher,
        );
      }
    }

    return googleBook;
  }
}
