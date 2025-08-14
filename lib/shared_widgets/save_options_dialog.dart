import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

typedef SaveResult = ({String fileName, String? folderPath});

Future<SaveResult?> showSaveOptionsDialog(
  BuildContext context, {
  required String defaultFileName,
  required String fileExtension,
}) {
  return showDialog<SaveResult>(
    context: context,
    builder: (context) {
      return _SaveOptionsDialog(
        defaultFileName: defaultFileName,
        fileExtension: fileExtension,
      );
    },
  );
}

class _SaveOptionsDialog extends ConsumerStatefulWidget {
  final String defaultFileName;
  final String fileExtension;

  const _SaveOptionsDialog({
    required this.defaultFileName,
    required this.fileExtension,
  });

  @override
  ConsumerState<_SaveOptionsDialog> createState() => _SaveOptionsDialogState();
}

class _SaveOptionsDialogState extends ConsumerState<_SaveOptionsDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _selectedFolderPath;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultFileName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final finalName = '${_controller.text.trim()}${widget.fileExtension}';
      Navigator.of(
        context,
      ).pop((fileName: finalName, folderPath: _selectedFolderPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFoldersAsync = ref.watch(allFoldersProvider);

    return AlertDialog(
      title: const Text('Save File'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'File Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a file name.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    widget.fileExtension,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedFolderPath,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Wallet (Root)'),
                ),
                if (allFoldersAsync.isLoading)
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                if (allFoldersAsync.hasValue)
                  ...allFoldersAsync.value!.map((folderPath) {
                    return DropdownMenuItem<String?>(
                      value: folderPath,
                      child: Text(folderPath.replaceAll(p.separator, ' / ')),
                    );
                  }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFolderPath = value;
                });
              },
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
