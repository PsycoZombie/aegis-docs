import 'dart:io';

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../shared_widgets/app_scaffold.dart';
import '../../wallet/providers/wallet_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final walletState = ref.watch(walletProvider);

    return AppScaffold(
      title: 'Aegis Docs',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () {
            ref.read(localAuthProvider.notifier).logout();
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.wallet_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('My Wallet', style: textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(walletProvider.notifier).refresh(),
                child: walletState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (files) {
                    if (files.isEmpty) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withAlpha(
                            (0.5 * 255).toInt(),
                          ),
                          border: Border.all(
                            color: colorScheme.outline.withAlpha(
                              (0.5 * 255).toInt(),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Your saved documents will appear here.'),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final fileName = p.basename(file.path);
                        return _DocumentCard(file: file, fileName: fileName);
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
          context.push('/hub').then((_) {
            ref.read(walletProvider.notifier).refresh();
          });
        },
        label: const Text('Start New Prep'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  const _DocumentCard({required this.file, required this.fileName});

  final File file;
  final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/document/$fileName');
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
                              .read(walletProvider.notifier)
                              .deleteDocument(fileName);
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
