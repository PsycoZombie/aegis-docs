// file: features/home/view/home_screen.dart

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/breadcrumb_navigation.dart';
import 'package:aegis_docs/features/home/widgets/document_card.dart';
import 'package:aegis_docs/features/home/widgets/folder_card.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new HomeViewModel for UI state like the current path.
    final homeState = ref.watch(homeViewModelProvider);
    final homeNotifier = ref.read(homeViewModelProvider.notifier);

    // Watch the WalletViewModel to get the list of files and folders for the current path.
    final walletState = ref.watch(
      walletViewModelProvider(homeState.currentFolderPath),
    );

    // Listen for info messages from the provider to show SnackBars
    ref.listen(homeViewModelProvider, (previous, next) {
      if (next.infoMessage != null &&
          previous?.infoMessage != next.infoMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.infoMessage!),
            backgroundColor:
                next.infoMessage!.startsWith('Failed') ||
                    next.infoMessage!.startsWith('Error')
                ? Colors.red
                : Colors.green,
          ),
        );
      }
    });

    return PopScope(
      canPop: homeState.currentFolderPath == null,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        // Navigation logic is now cleanly handled by the provider.
        homeNotifier.navigateUp();
      },
      child: AppScaffold(
        title: 'Secure Wallet',
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New Folder',
            onPressed: () => homeNotifier.createFolder(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(localAuthProvider.notifier).logout();
              }
              if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuDivider(),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/hub'),
          label: const Text('Start New Prep'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
