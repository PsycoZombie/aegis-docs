import 'package:flutter/material.dart';

/// Displays a dialog for renaming a file or folder.
///
/// [context]: The build context from which to show the dialog.
/// [currentName]: The initial text to populate the text field with.
/// [title]: The title to display on the dialog.
///
/// Returns the new name as a [String] if the user taps
/// "Rename", otherwise returns null.
Future<String?> showRenameDialog(
  BuildContext context, {
  required String currentName,
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return _RenameDialog(currentName: currentName, title: title);
    },
  );
}

/// The internal stateful widget that builds the content of the rename dialog.
class _RenameDialog extends StatefulWidget {
  /// Creates an instance of [_RenameDialog].
  const _RenameDialog({required this.currentName, required this.title});
  final String currentName;
  final String title;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Validates the form and pops the dialog, returning the new name.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Rename')),
      ],
    );
  }
}
