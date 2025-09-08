// lib/ui/account/widgets/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/account/state/account_screen_state.dart';
// Import the separate state class

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends AccountScreenState {
  // This will contain all the logic like handling authentication state, loading state, etc.
}
