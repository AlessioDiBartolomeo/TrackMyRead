import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_library_app/ui/statistics/widgets/statistics_screen.dart';
import 'package:flutter_library_app/data/repositories/statistics_repository.dart';
import 'package:flutter_library_app/ui/statistics/widgets/statistics_chart.dart';
import 'package:mocktail/mocktail.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('StatisticsScreen Tests', () {
    late MockStatisticsRepository mockStatisticsRepository;

    setUp(() {
      mockStatisticsRepository = MockStatisticsRepository();
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      // Prepare the mock to return empty data
      when(mockStatisticsRepository.getBooksPerAuthor(any as String) as Function()).thenAnswer((_) async => {});
      when(mockStatisticsRepository.getBooksPerPublisher(any as String) as Function()).thenAnswer((_) async => {});
      when(mockStatisticsRepository.getBooksPerGenre(any as String) as Function()).thenAnswer((_) async => {});
      when(mockStatisticsRepository.getBooksPerMonth(any as String) as Function()).thenAnswer((_) async => {});

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(),
      ));

      // Verify that the CircularProgressIndicator is displayed initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('fetches and displays statistics after loading', (WidgetTester tester) async {
      // Prepare the mock data for books per author, publisher, genre, and month
      final mockBooksPerAuthor = {'Author 1': 5, 'Author 2': 3};
      final mockBooksPerPublisher = {'Publisher 1': 7, 'Publisher 2': 4};
      final mockBooksPerGenre = {'Genre 1': 6, 'Genre 2': 2};
      final mockBooksPerMonth = {1: 10, 2: 15};

      when(mockStatisticsRepository.getBooksPerAuthor(any as String) as Function()).thenAnswer((_) async => mockBooksPerAuthor);
      when(mockStatisticsRepository.getBooksPerPublisher(any as String) as Function()).thenAnswer((_) async => mockBooksPerPublisher);
      when(mockStatisticsRepository.getBooksPerGenre(any as String) as Function()).thenAnswer((_) async => mockBooksPerGenre);
      when(mockStatisticsRepository.getBooksPerMonth(any as String) as Function()).thenAnswer((_) async => mockBooksPerMonth);

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(),
      ));

      // Pump to allow the state to update after fetching data
      await tester.pump();

      // Verify that the statistics are displayed on the screen
      expect(find.text('📚 Libri per autore'), findsOneWidget);
      expect(find.text('🏢 Libri per casa editrice'), findsOneWidget);
      expect(find.text('🎭 Libri per genere'), findsOneWidget);
      expect(find.text('📅 Libri per mese'), findsOneWidget);
    });

    testWidgets('opens chart page when a card is tapped', (WidgetTester tester) async {
      final mockBooksPerAuthor = {'Author 1': 5, 'Author 2': 3};
      final mockBooksPerPublisher = {'Publisher 1': 7, 'Publisher 2': 4};

      when(mockStatisticsRepository.getBooksPerAuthor(any as String) as Function()).thenAnswer((_) async => mockBooksPerAuthor);
      when(mockStatisticsRepository.getBooksPerPublisher(any as String) as Function()).thenAnswer((_) async => mockBooksPerPublisher);

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(),
      ));

      // Tap the "Libri per autore" card
      await tester.tap(find.text('📚 Libri per autore'));
      await tester.pumpAndSettle();

      // Verify that the StatisticsChart screen is shown
      expect(find.byType(StatisticsChart), findsOneWidget);
    });

    testWidgets('opens month chart page when "Libri per mese" is tapped', (WidgetTester tester) async {
      final mockBooksPerMonth = {1: 10, 2: 15};

      when(mockStatisticsRepository.getBooksPerMonth(any as String) as Function()).thenAnswer((_) async => mockBooksPerMonth);

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(),
      ));

      // Tap the "Libri per mese" card
      await tester.tap(find.text('📅 Libri per mese'));
      await tester.pumpAndSettle();

      // Verify that the StatisticsChart screen for month data is shown
      expect(find.byType(StatisticsChart), findsOneWidget);
    });
  });
}
