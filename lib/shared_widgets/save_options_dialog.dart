import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// A type definition for the result returned by the [showSaveOptionsDialog].
/// It contains the final file name and the optional folder path.
typedef SaveResult = ({String fileName, String? folderPath});

/// Displays a dialog for saving a single file with
/// a specified name and location.
///
/// [context]: The build context from which to show the dialog.
/// [defaultFileName]: The initial text to populate the file name field with.
/// [fileExtension]: The file extension to be appended to the final file name.
///
/// Returns a [SaveResult] record if the user taps
/// "Save", otherwise returns null.
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

/// The internal stateful widget that builds the content of the save dialog.
class _SaveOptionsDialog extends ConsumerStatefulWidget {
  const _SaveOptionsDialog({
    required this.defaultFileName,
    required this.fileExtension,
  });
  final String defaultFileName;
  final String fileExtension;

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

  /// Validates the form and pops the dialog, returning the save result.
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
    // Watch the provider that lists all folders in the wallet.
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
                  padding: const EdgeInsets.only(top: 16),
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
              isExpanded: true,
              // Build the list of folder options for the dropdown.
              items: [
                // The first item is always the root of the wallet.
                const DropdownMenuItem<String?>(child: Text('Wallet (Root)')),
                if (allFoldersAsync.hasValue)
                  ...allFoldersAsync.value!.map((folderPath) {
                    return DropdownMenuItem<String?>(
                      value: folderPath,
                      child: Text(
                        // Display nested paths with slashes for clarity.
                        folderPath.replaceAll(p.separator, ' / '),
                        overflow: TextOverflow.ellipsis,
                      ),
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
