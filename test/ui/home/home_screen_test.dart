import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/core/ui/stat_card.dart';
import 'package:flutter_library_app/ui/home/widgets/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/data/repositories/book_repository.dart';
import 'package:flutter_library_app/domain/models/book.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/home/widgets/books_read_chart.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  group('HomeScreen Tests', () {
    late MockBookRepository mockBookRepository;

    setUp(() {
      mockBookRepository = MockBookRepository();
    });

    testWidgets('renders HomeScreen with loading indicator initially', (WidgetTester tester) async {
      // Mock the repository to return a loading state
      when(mockBookRepository.loadBooks() as Function()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(), // No onTabChanged parameter here
      ));

      // Verify that the CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders HomeScreen with book data after loading', (WidgetTester tester) async {
      // Prepare test data for books
      final testBooks = [
        Book(
          bookName: 'Book 1',
          authorName: ['Author 1'],
          isbn: '123',
          status: 'reading',
          totalPages: 100,
          currentPage: 50,
          startDate: DateTime.now(),
          description: 'Test Book 1',
          imagePath: 'assets/book1.jpg',
          lastReadDate: DateTime.now().subtract(Duration(days: 2)),
          readCount: 0,
          publisher: 'Publisher 1',
          genres: [],
        ),
        Book(
          bookName: 'Book 2',
          authorName: ['Author 2'],
          isbn: '124',
          status: 'reading',
          totalPages: 200,
          currentPage: 100,
          startDate: DateTime.now(),
          description: 'Test Book 2',
          imagePath: 'assets/book2.jpg',
          lastReadDate: DateTime.now().subtract(Duration(days: 1)),
          readCount: 0,
          publisher: 'Publisher 2',
          genres: [],
        ),
      ];

      when(mockBookRepository.loadBooks() as Function()).thenAnswer((_) async => testBooks);

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(), // No onTabChanged parameter here
      ));

      // Pump the widget tree to show the loaded state
      await tester.pump();

      // Verify that the stats and books are rendered
      expect(find.text('Bentornato/a!'), findsOneWidget);
      expect(find.byType(StatCard), findsNWidgets(2)); // 2 StatCards should be shown
      expect(find.byType(BooksReadChart), findsOneWidget); // BooksReadChart widget should be present
      expect(find.byType(ListView), findsOneWidget); // A ListView should render the books
    });

    testWidgets('navigates to AddBook screen when "Add Book" button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          AppRoutes.addBook: (context) => Scaffold(), // Empty scaffold as a placeholder
        },
      ));

      // Tap the second navigation tab (which should navigate to AddBook)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify that we have navigated to the AddBook screen
      expect(find.byType(Scaffold), findsOneWidget); // Verifying the navigation to the AddBook screen
    });

    testWidgets('navigates to Account screen when "Account" tab is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          AppRoutes.account: (context) => Scaffold(), // Empty scaffold as a placeholder
        },
      ));

      // Tap the third navigation tab (which should navigate to Account)
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Verify that we have navigated to the Account screen
      expect(find.byType(Scaffold), findsOneWidget); // Verifying the navigation to the Account screen
    });

    testWidgets('loads and displays latest reading books carousel', (WidgetTester tester) async {
      // Prepare test data for the latest books
      final testBooks = [
        Book(
          bookName: 'Book 1',
          authorName: ['Author 1'],
          isbn: '123',
          status: 'reading',
          totalPages: 100,
          currentPage: 50,
          startDate: DateTime.now(),
          description: 'Test Book 1',
          imagePath: 'assets/book1.jpg',
          lastReadDate: DateTime.now(),
          readCount: 0,
          publisher: 'Publisher 1', 
          genres: [],
        ),
      ];

      when(mockBookRepository.loadBooks() as Function()).thenAnswer((_) async => testBooks);

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(), // No onTabChanged parameter here
      ));

      // Pump the widget tree to show the loaded state
      await tester.pump();

      // Verify that the latest books carousel is displayed
      expect(find.byType(ListView), findsOneWidget); // A ListView should render the books
      expect(find.byType(GestureDetector), findsOneWidget); // One book item in the carousel
    });
  });
}
