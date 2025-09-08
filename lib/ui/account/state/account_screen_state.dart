// lib/ui/account/widgets/account_screen_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/account/widgets/account_screen.dart';
import 'package:flutter_library_app/ui/account/widgets/auth_form.dart';
import 'package:flutter_library_app/data/services/auth_service.dart';
import 'package:flutter_library_app/ui/account/widgets/feature_item.dart';
import 'package:flutter_library_app/ui/account/widgets/user_header.dart';
import 'package:flutter_library_app/ui/core/ui/my_bottom_navigation_bar.dart';

abstract class AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  int _selectedIndex = 2;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to Home
        Navigator.pushNamed(
          context,
          AppRoutes.home,
        );
        break;
      case 1:
        // Navigate to Add Book Screen
        Navigator.pushNamed(
          context,
          AppRoutes.addBook,
        );
        break;
      case 2:
        // Account screen, no action needed.
        break;
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await AuthService().signOut();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            user != null
                ? UserHeader(user: user)
                : _buildLoginCard(),
            const SizedBox(height: 32),
            _buildFeaturesCard(),
            if (user != null) _buildLogoutCard(),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Card _buildLoginCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.account_circle,
              size: 72,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              "Accedi per sincronizzare i tuoi progressi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            const AuthForm(),
          ],
        ),
      ),
    );
  }

  Card _buildFeaturesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Funzionalità disponibili",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FeatureItem(icon: Icons.cloud_upload, label: "Backup su Drive"),
                FeatureItem(icon: Icons.sync, label: "Sincronizzazione"),
                FeatureItem(icon: Icons.security, label: "Sicurezza"),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Accedi con Google per abilitare il backup e la sincronizzazione dei tuoi libri e progressi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildLogoutCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.deepPurple, size: 28),
        title: const Text("Esci dall'account", style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
        onTap: _logout,
      ),
    );
  }
}
