// file: features/home/view/home_screen.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/rename_dialog.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _currentFolderPath;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletViewModelProvider(_currentFolderPath));
    final notifier = ref.read(
      walletViewModelProvider(_currentFolderPath).notifier,
    );

    return PopScope(
      canPop: _currentFolderPath == null,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        setState(() {
          final parent = p.dirname(_currentFolderPath!);
          _currentFolderPath = (parent == '.') ? null : parent;
        });
      },
      child: AppScaffold(
        title: 'Secure Wallet',
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New Folder',
            onPressed: () => _showCreateFolderDialog(context, notifier),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(localAuthProvider.notifier).logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BreadcrumbNavigation(
                path: _currentFolderPath,
                onPathChanged: (newPath) {
                  setState(() {
                    _currentFolderPath = newPath;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => notifier.refresh(),
                  child: walletState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    data: (state) {
                      if (state.folders.isEmpty && state.files.isEmpty) {
                        return const Center(
                          child: Text('This folder is empty.'),
                        );
                      }
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: state.folders.length + state.files.length,
                        itemBuilder: (context, index) {
                          if (index < state.folders.length) {
                            final folder = state.folders[index];
                            return _FolderCard(
                              folder: folder,
                              currentPath: _currentFolderPath,
                              onTap: () {
                                setState(() {
                                  final folderName = p.basename(folder.path);
                                  _currentFolderPath =
                                      _currentFolderPath == null
                                      ? folderName
                                      : p.join(_currentFolderPath!, folderName);
                                });
                              },
                            );
                          }
                          final fileIndex = index - state.folders.length;
                          final file = state.files[fileIndex];
                          return _DocumentCard(
                            file: file,
                            folderPath: _currentFolderPath,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/hub');
          },
          label: const Text('Start New Prep'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WalletViewModel notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Folder Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final success = await notifier.createFolder(
                    folderName: controller.text,
                    parentFolderPath: _currentFolderPath,
                  );
                  if (success && context.mounted) {
                    context.pop();
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'A folder named "${controller.text}" already exists.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

// --- Helper Widgets ---

class _FolderCard extends ConsumerWidget {
  final Directory folder;
  final String? currentPath;
  final VoidCallback onTap;

  const _FolderCard({
    required this.folder,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderName = p.basename(folder.path);
    final folderPath = currentPath == null
        ? folderName
        : p.join(currentPath!, folderName);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context, ref, folderPath, true),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 50, color: Colors.amber),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                folderName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final File file;
  final String? folderPath;

  const _DocumentCard({required this.file, this.folderPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileName = p.basename(file.path);
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: () => context.push('/document/$fileName', extra: folderPath),
      onLongPress: () => _showContextMenu(context, ref, fileName, false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(fileName, overflow: TextOverflow.ellipsis),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.image,
            size: 60,
            color: isPdf ? Colors.red.shade300 : Colors.blue.shade300,
          ),
        ),
      ),
    );
  }
}

// --- Context Menu Logic ---

void _showContextMenu(
  BuildContext context,
  WidgetRef ref,
  String path,
  bool isFolder,
) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final RenderBox button = context.findRenderObject() as RenderBox;
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<String>(
    context: context,
    position: position,
    items: [
      if (!isFolder) ...[
        const PopupMenuItem<String>(
          value: 'export',
          child: ListTile(
            leading: Icon(Icons.save_alt),
            title: Text('Export to Device'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(leading: Icon(Icons.share), title: Text('Share')),
        ),
        const PopupMenuDivider(),
      ],
      const PopupMenuItem<String>(
        value: 'rename',
        child: ListTile(leading: Icon(Icons.edit), title: Text('Rename')),
      ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ),
    ],
  ).then((String? value) {
    if (value == null) return;

    final currentFolderPath = (context as Element)
        .findAncestorStateOfType<_HomeScreenState>()
        ?._currentFolderPath;
    final notifier = ref.read(
      walletViewModelProvider(currentFolderPath).notifier,
    );

    switch (value) {
      case 'rename':
        _handleRename(context, notifier, path, isFolder, currentFolderPath);
        break;
      case 'delete':
        _handleDelete(context, notifier, path, isFolder, currentFolderPath);
        break;
      case 'export':
        _handleExport(context, notifier, path, currentFolderPath);
        break;
      case 'share':
        _handleShare(context, notifier, path, currentFolderPath);
        break;
    }
  });
}

Future<void> _handleExport(
  BuildContext context,
  WalletViewModel notifier,
  String fileName,
  String? folderPath,
) async {
  try {
    final decryptedBytes = await notifier.exportDocument(
      fileName: fileName,
      folderPath: folderPath,
    );

    if (decryptedBytes == null) {
      throw Exception('Failed to load document.');
    }

    // Use FileSaver to open the native "Save As..." dialog.
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(decryptedBytes),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _handleShare(
  BuildContext context,
  WalletViewModel notifier,
  String fileName,
  String? folderPath,
) async {
  try {
    final decryptedBytes = await notifier.exportDocument(
      fileName: fileName,
      folderPath: folderPath,
    );

    if (decryptedBytes == null) {
      throw Exception('Failed to load document for sharing.');
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = await File(
      '${tempDir.path}/$fileName',
    ).writeAsBytes(decryptedBytes);

    final params = ShareParams(
      text: 'Great picture',
      files: [XFile('${tempFile.path}/image.jpg')],
    );

    await SharePlus.instance.share(params);

    await tempFile.delete();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _handleRename(
  BuildContext context,
  WalletViewModel notifier,
  String path,
  bool isFolder,
  String? currentFolderPath,
) async {
  final currentName = isFolder
      ? p.basename(path)
      : p.basenameWithoutExtension(path);
  final newName = await showRenameDialog(
    context,
    currentName: currentName,
    title: isFolder ? 'Rename Folder' : 'Rename File',
  );

  if (newName != null && newName.isNotEmpty && newName != currentName) {
    if (isFolder) {
      await notifier.renameFolder(oldPath: path, newName: newName);
    } else {
      final extension = p.extension(path);
      await notifier.renameFile(
        oldName: p.basename(path),
        newName: '$newName$extension',
        folderPath: currentFolderPath,
      );
    }
  }
}

void _handleDelete(
  BuildContext context,
  WalletViewModel notifier,
  String path,
  bool isFolder,
  String? currentFolderPath,
) {
  final name = p.basename(path);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isFolder ? 'Delete Folder?' : 'Delete Document?'),
      content: Text(
        'Are you sure you want to delete "$name"?\n${isFolder ? 'This will delete all contents inside.' : ''}\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(child: const Text('Cancel'), onPressed: () => context.pop()),
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () {
            if (isFolder) {
              notifier.deleteFolder(folderPathToDelete: path);
            } else {
              notifier.deleteDocument(
                fileName: name,
                folderPath: currentFolderPath,
              );
            }
            context.pop();
          },
        ),
      ],
    ),
  );
}

class _BreadcrumbNavigation extends StatelessWidget {
  final String? path;
  final ValueChanged<String?> onPathChanged;

  const _BreadcrumbNavigation({
    required this.path,
    required this.onPathChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parts = path?.split(p.separator) ?? [];
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length + 1,
        separatorBuilder: (context, index) => const Center(
          child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: InkWell(
                onTap: () => onPathChanged(null),
                child: const Text(
                  'Wallet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
          final partIndex = index - 1;
          final currentPart = parts[partIndex];
          final currentPath = p.joinAll(parts.sublist(0, partIndex + 1));
          return Center(
            child: InkWell(
              onTap: () => onPathChanged(currentPath),
              child: Text(currentPart),
            ),
          );
        },
      ),
    );
  }
}
