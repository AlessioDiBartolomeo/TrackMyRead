import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/domain/models/book.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {
  // Simulate saving a book to local storage
  @override
  Future<void> saveBookToLocalStorage(Book book) {
    return Future.value(); // Return a completed Future
  }

  // Simulate saving a book to Firestore
  @override
  Future<void> saveBookToFirestore(Book book) {
    return Future.value(); // Return a completed Future
  }

  // Simulate fetching a book by ISBN (this method should exist in BookRepository)
  @override
  // ignore: override_on_non_overriding_member
  Future<Book?> fetchBookByISBN(String isbn) {
    return Future.value(Book(
      bookName: 'Test Book',
      authorName: ['Test Author'],
      isbn: isbn,
      status: 'not read',
      totalPages: 100,
      currentPage: 0,
      startDate: null,
      description: 'A test book description',
      imagePath: '',
      lastReadDate: null,
      endDate: null,
      readCount: 0,
      publisher: 'Test Publisher', 
      genres: [],
    ));
  }

  // Simulate checking if a book exists in Firestore
  @override
  // ignore: override_on_non_overriding_member
  Future<bool> doesBookExistInFirestore(String isbn) {
    return Future.value(false); // Return false indicating book doesn't exist
  }
}
