import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      title: 'Aegis Docs',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            ref.read(localAuthProvider.notifier).logout();
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.wallet_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('My Wallet', style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(128),
                border: Border.all(color: colorScheme.outline.withAlpha(128)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Your saved documents will appear here.'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Icon(Icons.people_outline, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Profiles', style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(128),
                border: Border.all(color: colorScheme.outline.withAlpha(51)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('User profiles will appear here.'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/prep');
        },
        label: const Text('Start New Prep'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
