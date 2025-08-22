import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:aegis_docs/features/settings/view/master_password_screen.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<SettingsService> settingsServiceProvider = Provider(
  (ref) => SettingsService(),
);

final cleanupDurationProvider = StateProvider<CleanupDuration>((ref) {
  return CleanupDuration.oneDay;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final settingsService = ref.read(settingsServiceProvider);
    final savedDuration = await settingsService.loadCleanupDuration();
    if (mounted) {
      ref.read(cleanupDurationProvider.notifier).state = savedDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    // THE FIX: Watch the new view model provider.
    final settingsState = ref.watch(settingsViewModelProvider);

    // THE FIX: Listen for success/error messages from the provider.
    ref.listen(settingsViewModelProvider, (_, next) {
      if (next is AsyncData) {
        final state = next.value;
        if (state!.successMessage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.errorMessage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ... (Your existing Card for Export Settings is unchanged) ...
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cloud Sync',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Securely back up your encrypted wallet to Google Drive. '
                    'A master password is required.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  settingsState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (state) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Backup'),
                          // Disable button while processing
                          onPressed: state.isProcessing
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<dynamic>(
                                      builder: (_) => MasterPasswordScreen(
                                        isCreating: true,
                                        onSubmit: (password) async {
                                          // Call the provider method
                                          await ref
                                              .read(
                                                settingsViewModelProvider
                                                    .notifier,
                                              )
                                              .backupWallet(password);
                                        },
                                      ),
                                    ),
                                  );
                                },
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: const Icon(Icons.cloud_download_outlined),
                          label: const Text('Restore'),
                          onPressed: state.isProcessing
                              ? null
                              : () async {
                                  // THE FIX: Call the new download method first
                                  final backupBytes = await ref
                                      .read(settingsViewModelProvider.notifier)
                                      .downloadBackup();
                                  if (backupBytes != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Backup found! '
                                          'Please enter your password.',
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<dynamic>(
                                        builder: (_) => MasterPasswordScreen(
                                          isCreating: false,
                                          // Pass the downloaded bytes to
                                          //the next screen
                                          backupBytes: backupBytes,
                                          onSubmit: (password) async {
                                            // The master password screen now
                                            // calls the finishRestore method
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 12),
                        // NEW: Delete Backup Button
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            // THE FIX: Add an explicit text style.
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: const Text('Delete Cloud Backup'),
                          onPressed: state.isProcessing
                              ? null
                              : () =>
                                    _showDeleteConfirmationDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                  // Show a linear progress indicator at the bottom of the
                  // card while processing
                  if (settingsState.valueOrNull?.isProcessing ?? false) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
  showDialog<dynamic>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Cloud Backup?'),
      content: const Text(
        'Are you sure you want to permanently delete your backup from '
        'Google Drive? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
          onPressed: () {
            ref.read(settingsViewModelProvider.notifier).deleteBackup();
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}
