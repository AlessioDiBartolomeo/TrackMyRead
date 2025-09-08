import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/add_book/widgets/add_book_screen.dart';
import 'package:flutter_library_app/ui/core/ui/custom_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/domain/models/book.dart';
import 'package:flutter_library_app/ui/add_book/widgets/add_book_button.dart';
import 'package:flutter_library_app/ui/add_book/widgets/book_pages_field.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {
  @override
  Future<void> saveBookToLocalStorage(Book book) {
    return Future.value();
  }

  @override
  Future<void> saveBookToFirestore(Book book) {
    return Future.value(); 
  }

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

  @override
  // ignore: override_on_non_overriding_member
  Future<bool> doesBookExistInFirestore(String isbn) {
    return Future.value(false); // Simulate checking Firestore
  }
}

void main() {
  group('AddBookScreen Tests', () {
    testWidgets('renders AddBookScreen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AddBookScreen(onTabChanged: (index) {}),
      ));

      // Use a specific Finder for the title, if possible.
      expect(find.byWidgetPredicate((widget) =>
          widget is Text && widget.data == 'Aggiungi Libro'), findsOneWidget);
    });

    testWidgets('should enable save button when form is valid', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AddBookScreen(onTabChanged: (index) {}),
      ));

      // Fill out the required fields
      await tester.enterText(find.byType(CustomTextField).at(0), 'Test Book');
      await tester.enterText(find.byType(CustomTextField).at(1), 'Test Author');
      await tester.enterText(find.byType(CustomTextField).at(2), 'Fiction');
      await tester.enterText(find.byType(CustomTextField).at(3), 'Test Publisher');
      await tester.enterText(find.byType(BookPagesField), '100'); 

      // Rebuild widget after text input
      await tester.pump();

      final addButton = find.byType(AddBookButton);
      final addButtonWidget = tester.widget<AddBookButton>(addButton);

      // Expect the button to be enabled now
      expect(addButtonWidget.enabled, true);
    });

    testWidgets('should save book when save button is pressed', (WidgetTester tester) async {
      // Create a mock BookRepository
      final mockBookRepository = MockBookRepository();

      await tester.pumpWidget(MaterialApp(
        home: AddBookScreen(onTabChanged: (index) {}),
      ));

      // Fill out the form
      await tester.enterText(find.byType(CustomTextField).at(0), 'Test Book');
      await tester.enterText(find.byType(CustomTextField).at(1), 'Test Author');
      await tester.enterText(find.byType(CustomTextField).at(2), 'Fiction');
      await tester.enterText(find.byType(CustomTextField).at(3), 'Test Publisher');
      await tester.enterText(find.byType(BookPagesField), '100');

      // Rebuild widget after text input
      await tester.pump();

      // Scroll the view to bring the button into view if it's off-screen
      await tester.scrollUntilVisible(find.byType(AddBookButton), 200);

      // Tap the save button
      await tester.tap(find.byType(AddBookButton));
      await tester.pump();

      // Verify that the book was saved 
      verify(mockBookRepository.saveBookToLocalStorage(any as Book) as Function()).called(1);
      verify(mockBookRepository.saveBookToFirestore(any as Book) as Function()).called(1);
    });
  });
}
