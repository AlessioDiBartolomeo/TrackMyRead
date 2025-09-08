import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../../../data/services/auth_service.dart';

class AuthForm extends StatelessWidget {
  const AuthForm({super.key});

  void _googleSignIn(BuildContext context) async {
    try {
      await AuthService().signInWithGoogle();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in to backup your library to Google Drive',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Google Sign-In button
            SignInButton(
              Buttons.google,
              onPressed: () => _googleSignIn(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'You can continue using the app without signing in.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
