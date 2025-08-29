import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:aegis_docs/features/settings/view/master_password_screen.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_screen.g.dart';

/// A provider that manages the state of the cleanup duration setting.
///
/// It asynchronously loads the initial value from storage and provides a method
/// to update and persist the new value.
@riverpod
class CleanupDurationSetting extends _$CleanupDurationSetting {
  @override
  Future<CleanupDuration> build() async {
    // Load the initial value from the settings service.
    return ref.watch(settingsServiceProvider).loadCleanupDuration();
  }

  /// Updates the cleanup duration and saves it to persistent storage.
  Future<void> setDuration(CleanupDuration duration) async {
    state = AsyncData(duration);
    await ref.read(settingsServiceProvider).saveCleanupDuration(duration);
  }
}

/// A screen for managing application-level settings, such as cloud sync and
/// automatic file cleanup.
class SettingsScreen extends ConsumerWidget {
  /// Creates an instance of [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
    final cleanupDurationState = ref.watch(cleanupDurationSettingProvider);
    final cleanupDurationNotifier = ref.read(
      cleanupDurationSettingProvider.notifier,
    );

    final isProcessing = settingsState.isLoading;

    return AppScaffold(
      title: AppConstants.titleSettings,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCloudSyncCard(
            context,
            ref,
            isProcessing,
            settingsNotifier,
          ),
          const SizedBox(height: 16),
          _buildCleanupCard(
            context,
            cleanupDurationState,
            cleanupDurationNotifier,
          ),
        ],
      ),
    );
  }

  /// Builds the UI card for cloud sync options.
  Widget _buildCloudSyncCard(
    BuildContext context,
    WidgetRef ref,
    bool isProcessing,
    SettingsViewModel notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cloud Sync', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Securely back up your encrypted wallet to Google Drive. '
              'A master password is required.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Backup'),
                  onPressed: isProcessing
                      ? null
                      : () => _onBackupPressed(context, notifier),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Restore'),
                  onPressed: isProcessing
                      ? null
                      : () => _onRestorePressed(context, ref, notifier),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                style: ButtonStyle(
                  // This property gives us full control over
                  // the TextStyle in different states
                  textStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                    states,
                  ) {
                    final baseStyle = Theme.of(context).textTheme.labelLarge;
                    // Check if the button is in the 'disabled' state
                    if (states.contains(WidgetState.disabled)) {
                      // Return a style for the disabled state
                      return baseStyle?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(80),
                      );
                    }
                    // Return a style for all other states
                    // (enabled, pressed, etc.)
                    return baseStyle?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    );
                  }),
                  // We also need to define the icon color for different states
                  iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(80);
                    }
                    return Theme.of(context).colorScheme.error;
                  }),
                ),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(
                  'Delete Cloud Backup',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: isProcessing
                    ? null
                    : () => _showDeleteConfirmationDialog(
                        context,
                        ref,
                        notifier,
                      ),
              ),
            ),
            if (isProcessing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the UI card for cleanup duration options.
  Widget _buildCleanupCard(
    BuildContext context,
    AsyncValue<CleanupDuration> state,
    CleanupDurationSetting notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cleanup', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Automatically delete exported files from your device after a '
              'set period to maintain privacy.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (duration) => DropdownButtonFormField<CleanupDuration>(
                value: duration,
                decoration: const InputDecoration(
                  labelText: 'Cleanup after',
                  border: OutlineInputBorder(),
                ),
                items: CleanupDuration.values.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(_durationToString(d)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    notifier.setDuration(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the logic when the "Backup" button is pressed.
  void _onBackupPressed(BuildContext context, SettingsViewModel notifier) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => MasterPasswordScreen(
          isCreating: true,
          onSubmit: (password) async {
            final success = await notifier.backupWallet(password);
            if (context.mounted) {
              if (success) {
                showToast(context, 'Backup successful!');
              } else {
                showToast(
                  context,
                  'Backup failed. Please try again.',
                  type: ToastType.error,
                );
              }
              if (success) Navigator.of(context).pop();
            }
            return success;
          },
        ),
      ),
    );
  }

  /// Handles the logic when the "Restore" button is pressed.
  Future<void> _onRestorePressed(
    BuildContext context,
    WidgetRef ref,
    SettingsViewModel notifier,
  ) async {
    final backupBytes = await notifier.downloadBackup();
    if (backupBytes == null && context.mounted) {
      showToast(
        context,
        'No backup found on Google Drive.',
        type: ToastType.error,
      );
    }

    if (backupBytes != null && context.mounted) {
      showToast(
        context,
        'Backup found! Please enter your password to restore.',
        type: ToastType.info,
      );

      await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
          builder: (_) => MasterPasswordScreen(
            isCreating: false,
            backupBytes: backupBytes,
            onSubmit: (password) async {
              final success = await notifier.finishRestore(
                backupBytes,
                password,
              );
              if (context.mounted) {
                if (success) {
                  showToast(context, 'Restore successful!');
                } else {
                  showToast(
                    context,
                    'Restore failed. Please check your password.',
                    type: ToastType.error,
                  );
                }
              }
              return success;
            },
          ),
        ),
      );
    }
  }

  /// Shows the confirmation dialog for deleting a cloud backup.
  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsViewModel notifier,
  ) {
    showDialog<void>(
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
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog first

              final authService = ref.read(authServiceProvider);
              final isAuthenticated = await authService.authenticate();

              if (isAuthenticated && context.mounted) {
                final result = await notifier.deleteBackup();
                if (context.mounted) {
                  switch (result) {
                    case DeleteBackupResult.success:
                      showToast(context, 'Cloud backup deleted successfully!');
                    case DeleteBackupResult.notFound:
                      showToast(
                        context,
                        'No cloud backup found to delete.',
                        type: ToastType.warning,
                      );
                    case DeleteBackupResult.error:
                      showToast(
                        context,
                        'Failed to delete backup.',
                        type: ToastType.error,
                      );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Converts a [CleanupDuration] enum to a human-readable string.
  String _durationToString(CleanupDuration duration) {
    switch (duration) {
      case CleanupDuration.fiveMinutes:
        return '5 Minutes';
      case CleanupDuration.oneHour:
        return '1 Hour';
      case CleanupDuration.oneDay:
        return '1 Day';
      case CleanupDuration.sevenDays:
        return '7 Days';
      case CleanupDuration.never:
        return 'Never';
    }
  }
}
