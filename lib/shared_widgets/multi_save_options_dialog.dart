import 'package:flutter/material.dart';

Future<String?> showMultiSaveOptionsDialog(
  BuildContext context, {
  required String defaultBaseName,
  required int fileCount,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return _MultiSaveOptionsDialog(
        defaultBaseName: defaultBaseName,
        fileCount: fileCount,
      );
    },
  );
}

class _MultiSaveOptionsDialog extends StatefulWidget {
  final String defaultBaseName;
  final int fileCount;

  const _MultiSaveOptionsDialog({
    required this.defaultBaseName,
    required this.fileCount,
  });

  @override
  State<_MultiSaveOptionsDialog> createState() =>
      __MultiSaveOptionsDialogState();
}

class __MultiSaveOptionsDialogState extends State<_MultiSaveOptionsDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultBaseName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Multiple Images'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Base File Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a base name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'This will save ${widget.fileCount} images, for example:\n"${_controller.text.trim()}_page_1.png"',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
