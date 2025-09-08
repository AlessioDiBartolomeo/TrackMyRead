import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/book_detail/state/book_detail_state.dart';
import '../../../domain/models/book.dart';

class BookDetailScreen extends StatefulWidget {
  final Book entry;

  const BookDetailScreen({super.key, required this.entry});

  @override
  State<BookDetailScreen> createState() => BookDetailScreenState();
}