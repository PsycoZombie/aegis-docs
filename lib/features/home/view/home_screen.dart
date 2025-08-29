import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/breadcrumb_navigation.dart';
import 'package:aegis_docs/features/home/widgets/document_card.dart';
import 'package:aegis_docs/features/home/widgets/expanding_fab.dart';
import 'package:aegis_docs/features/home/widgets/folder_card.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// The main screen of the application, displaying
/// the contents of the secure wallet.
class HomeScreen extends ConsumerWidget {
  /// Creates an instance of [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    final walletState = ref.watch(
      walletViewModelProvider(homeState.currentFolderPath),
    );
    final isSelectionMode = homeState.isSelectionMode;

    return PopScope(
      canPop: !isSelectionMode && homeState.currentFolderPath == null,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (isSelectionMode) {
          homeNotifier.clearSelection();
        } else {
          homeNotifier.navigateUp();
        }
      },
      child: Scaffold(
        appBar: isSelectionMode
            ? _buildSelectionAppBar(context, ref)
            : _buildDefaultAppBar(context, ref),
        floatingActionButton: isSelectionMode ? null : const ExpandingFab(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BreadcrumbNavigation(
                path: homeState.currentFolderPath,
                onPathChanged: homeNotifier.navigateToPath,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                    walletViewModelProvider(homeState.currentFolderPath),
                  ),
                  child: walletState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    data: (data) {
                      if (data.folders.isEmpty && data.files.isEmpty) {
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
                        itemCount: data.folders.length + data.files.length,
                        itemBuilder: (context, index) {
                          if (index < data.folders.length) {
                            final folder = data.folders[index];
                            final isSelected = homeState.selectedItems.contains(
                              folder.path,
                            );
                            return GestureDetector(
                              onLongPress: () =>
                                  homeNotifier.enableSelectionMode(folder.path),
                              onTap: () {
                                if (isSelectionMode) {
                                  homeNotifier.toggleItemSelection(folder.path);
                                } else {
                                  homeNotifier.navigateToFolder(folder.name);
                                }
                              },
                              child: FolderCard(
                                folder: folder,
                                isSelected: isSelected,
                              ),
                            );
                          }
                          final fileIndex = index - data.folders.length;
                          final file = data.files[fileIndex];
                          final isSelected = homeState.selectedItems.contains(
                            file.path,
                          );
                          return GestureDetector(
                            onLongPress: () =>
                                homeNotifier.enableSelectionMode(file.path),
                            onTap: () {
                              if (isSelectionMode) {
                                homeNotifier.toggleItemSelection(file.path);
                              } else {
                                context.push(
                                  '/document/${file.name}',
                                  extra: homeState.currentFolderPath,
                                );
                              }
                            },
                            child: DocumentCard(
                              file: file,
                              isSelected: isSelected,
                            ),
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
      ),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    final themeToggleButton = IconButton(
      tooltip: 'Toggle Theme',
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
    );
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    return AppBar(
      title: const Text(AppConstants.titleSecureWallet),
      actions: [
        themeToggleButton,
        IconButton(
          icon: const Icon(Icons.create_new_folder_outlined),
          tooltip: AppConstants.titleNewFolder,
          onPressed: () async {
            final folderName = await _showCreateFolderDialog(context);
            if (folderName != null && folderName.isNotEmpty) {
              final success = await homeNotifier.createFolder(folderName);
              if (context.mounted) {
                if (success) {
                  showToast(context, 'Folder "$folderName" created.');
                } else {
                  showToast(
                    context,
                    'A folder named "$folderName" already exists.',
                    type: ToastType.warning,
                  );
                }
              }
            }
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              ref.read(localAuthProvider.notifier).logout();
            }
            if (value == 'settings') {
              await context.push(AppConstants.routeSettings);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(AppConstants.titleSettings),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(AppConstants.titleLogout),
              ),
            ),
          ],
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    final selectedItems = ref.watch(homeViewModelProvider).selectedItems;
    final selectedCount = selectedItems.length;
    final canShare = selectedItems.any((path) => p.extension(path).isNotEmpty);
    final isSingleSelection = selectedCount == 1;
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    final themeToggleButton = IconButton(
      tooltip: 'Toggle Theme',
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
    );

    return AppBar(
      title: Text('$selectedCount selected'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: homeNotifier.clearSelection,
      ),
      actions: [
        themeToggleButton,
        if (isSingleSelection)
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: 'Rename',
            onPressed: () async {
              final itemToRename = selectedItems.first;
              final currentName = p.basenameWithoutExtension(itemToRename);
              final isFolder = p.extension(itemToRename).isEmpty;

              final newName = await _showRenameDialog(context, currentName);
              if (newName != null && newName.isNotEmpty) {
                await homeNotifier.renameItem(
                  itemToRename,
                  newName,
                  isFolder: isFolder,
                );
                homeNotifier
                    .clearSelection(); // Exit selection mode after rename
                if (context.mounted) {
                  showToast(context, 'Item renamed to "$newName"');
                }
              }
            },
          ),
        if (canShare)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share selected files',
            onPressed: () async {
              final result = await homeNotifier.shareSelectedItems();
              if (context.mounted && result != null) {
                showToast(context, result, type: ToastType.error);
              }
            },
          ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete selected items',
          onPressed: () async {
            final confirm = await _showDeleteConfirmationDialog(
              context,
              selectedCount,
            );
            if (confirm ?? false) {
              await homeNotifier.deleteSelectedItems();
              if (context.mounted) {
                showToast(context, '$selectedCount items deleted.');
              }
            }
          },
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, int count) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items?'),
        content: Text(
          'Are you sure you want to delete these $count items?'
          ' This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // A dialog for renaming items
  Future<String?> _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Name'),
            autofocus: true,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  /// A helper method to show the "Create Folder" dialog.
  Future<String?> _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
