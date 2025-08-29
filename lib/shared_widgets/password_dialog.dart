import 'package:flutter/material.dart';

/// Displays a dialog to prompt the user for a password.
///
/// Returns the entered password as a [String] if the user taps "Unlock".
/// Returns `null` if the user cancels the dialog.
Future<String?> showPasswordDialog(BuildContext context) {
  final passwordController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // User must choose an action
    builder: (context) {
      return AlertDialog(
        title: const Text('Password Required'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Enter Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Returns null
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Returns the text
              Navigator.pop(context, passwordController.text);
            },
            child: const Text('Unlock'),
          ),
        ],
      );
    },
  );
}
