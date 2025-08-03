import 'dart:io';

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../shared_widgets/app_scaffold.dart';
import '../../wallet/providers/wallet_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return AppScaffold(
      title: 'Aegis Docs',
      actions: [
        // 1. Neumorphic Logout Button
        NeumorphicButton(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            shape: NeumorphicShape.flat,
          ),
          padding: const EdgeInsets.all(12),
          tooltip: 'Logout',
          onPressed: () {
            ref.read(localAuthProvider.notifier).logout();
          },
          child: Icon(
            Icons.logout,
            color: NeumorphicTheme.defaultTextColor(context),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.wallet_outlined,
                color: NeumorphicTheme.accentColor(context),
              ),
              const SizedBox(width: 8),
              NeumorphicText(
                'My Wallet',
                style: NeumorphicStyle(
                  disableDepth: true,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(walletProvider.notifier).refresh(),
              child: walletState.when(
                // 2. Neumorphic Loading Indicator
                loading: () =>
                    const Center(child: NeumorphicProgressIndeterminate()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (files) {
                  if (files.isEmpty) {
                    // 3. Neumorphic "Empty State" Container
                    return Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4, // Inset appearance
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(16),
                        ),
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
                      // 4. Use the new Neumorphic Document Card
                      return _NeumorphicDocumentCard(
                        file: file,
                        fileName: fileName,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // 5. Neumorphic Floating Action Button
      floatingActionButton: NeumorphicButton(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.stadium(),
          depth: 4,
          color: NeumorphicTheme.defaultTextColor(context),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        onPressed: () {
          context.push('/hub').then((_) {
            ref.read(walletProvider.notifier).refresh();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: NeumorphicTheme.baseColor(context)),
            const SizedBox(width: 8),
            Text(
              'Start New Prep',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: NeumorphicTheme.baseColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicDocumentCard extends ConsumerWidget {
  const _NeumorphicDocumentCard({required this.file, required this.fileName});

  final File file;
  final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    // 1. The root is now a NeumorphicButton to make the whole card tappable.
    return NeumorphicButton(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 4,
      ),
      padding: EdgeInsets.zero, // Remove padding to allow Stack to fill
      onPressed: () {
        context.push('/document/$fileName');
      },
      child: Stack(
        children: [
          // Main content
          Center(
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              size: 60,
              // 2. Replaced withOpacity() with Color.fromARGB()
              color: isPdf
                  ? const Color.fromARGB(
                      178,
                      239,
                      83,
                      80,
                    ) // Colors.red.shade300
                  : const Color.fromARGB(
                      178,
                      100,
                      181,
                      246,
                    ), // Colors.blue.shade300
            ),
          ),
          // Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // 3. Wrapped in ClipRRect to get rounded bottom corners
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 0,
                  color: Colors.black.withAlpha(
                    (0.4 * 255).toInt(),
                  ), // withOpacity is fine here
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          // Delete Button
          Positioned(
            top: 4,
            right: 4,
            child: NeumorphicButton(
              style: const NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.flat,
                depth: 2,
              ),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
