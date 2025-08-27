import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/breadcrumb_navigation.dart';
import 'package:aegis_docs/features/home/widgets/document_card.dart';
import 'package:aegis_docs/features/home/widgets/expanding_fab.dart';
import 'package:aegis_docs/features/home/widgets/folder_card.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return PopScope(
      canPop: homeState.currentFolderPath == null,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        homeNotifier.navigateUp();
      },
      child: AppScaffold(
        floatingActionButton: const ExpandingFab(),
        title: AppConstants.titleSecureWallet,
        actions: [
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
        body: Stack(
          children: [
            Padding(
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
                                return FolderCard(folder: folder);
                              }
                              final fileIndex = index - data.folders.length;
                              final file = data.files[fileIndex];
                              return DocumentCard(file: file);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
