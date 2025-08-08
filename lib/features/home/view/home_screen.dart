import 'dart:io';

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

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

class _FolderCard extends StatelessWidget {
  final Directory folder;
  final VoidCallback onTap;

  const _FolderCard({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 50, color: Colors.amber),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                p.basename(folder.path),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/document/$fileName', extra: folderPath);
        },
        child: GridTile(
          header: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Document?'),
                    content: Text(
                      'Are you sure you want to delete "$fileName"?',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => context.pop(),
                      ),
                      TextButton(
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          ref
                              .read(
                                walletViewModelProvider(folderPath).notifier,
                              )
                              .deleteDocument(
                                fileName: fileName,
                                folderPath: folderPath,
                              );
                          context.pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
