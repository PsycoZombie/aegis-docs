import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

typedef MultiSaveResult = ({String baseName, String? folderPath});

Future<MultiSaveResult?> showMultiSaveOptionsDialog(
  BuildContext context, {
  required String defaultBaseName,
  required int fileCount,
}) {
  return showDialog<MultiSaveResult>(
    context: context,
    builder: (context) {
      return _MultiSaveOptionsDialog(
        defaultBaseName: defaultBaseName,
        fileCount: fileCount,
      );
    },
  );
}

class _MultiSaveOptionsDialog extends ConsumerStatefulWidget {
  const _MultiSaveOptionsDialog({
    required this.defaultBaseName,
    required this.fileCount,
  });
  final String defaultBaseName;
  final int fileCount;

  @override
  ConsumerState<_MultiSaveOptionsDialog> createState() =>
      _MultiSaveOptionsDialogState();
}

class _MultiSaveOptionsDialogState
    extends ConsumerState<_MultiSaveOptionsDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _selectedFolderPath;

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
      Navigator.of(context).pop((
        baseName: _controller.text.trim(),
        folderPath: _selectedFolderPath,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFoldersAsync = ref.watch(allFoldersProvider);

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
            DropdownButtonFormField<String?>(
              value: _selectedFolderPath,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(child: Text('Wallet (Root)')),
                if (allFoldersAsync.hasValue)
                  ...allFoldersAsync.value!.map((folderPath) {
                    return DropdownMenuItem<String?>(
                      value: folderPath,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              folderPath.replaceAll(p.separator, ' / '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
            const SizedBox(height: 16),
            Text(
              'This will save ${widget.fileCount} images, for example:\n"'
              '${_controller.text.trim()}_page_1.png"',
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
