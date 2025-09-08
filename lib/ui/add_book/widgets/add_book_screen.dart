import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/add_book/state/add_book_screen_state.dart';

class AddBookScreen extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const AddBookScreen({super.key, this.onTabChanged});

  @override
  State<AddBookScreen> createState() => AddBookScreenState();
}


