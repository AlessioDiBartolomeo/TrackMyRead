import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final user;

  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.deepPurple[100],
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 48, color: Colors.deepPurple)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? "",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            if (user.email != null)
              Text(
                user.email!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
