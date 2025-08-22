import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@immutable
class SettingsState {
  const SettingsState({
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });
  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  SettingsState copyWith({
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
  }) {
    return SettingsState(
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  Future<SettingsState> build() async {
    return const SettingsState();
  }

  Future<void> backupWallet(String masterPassword) async {
    state = const AsyncValue.data(SettingsState(isProcessing: true));
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.backupWalletToDrive(masterPassword);
      state = const AsyncValue.data(
        SettingsState(successMessage: 'Backup successful!'),
      );
    } on Exception catch (e) {
      debugPrint('Backup failed: $e');
      state = AsyncValue.data(SettingsState(errorMessage: 'Backup failed: $e'));
    }
  }

  // THE FIX: The restore logic is now split into two methods.

  /// Step 1: Tries to download the backup and returns the data.
  Future<Uint8List?> downloadBackup() async {
    state = const AsyncValue.data(SettingsState(isProcessing: true));
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final backupBytes = await repo.downloadBackupFromDrive();

      if (backupBytes == null) {
        state = const AsyncValue.data(
          SettingsState(errorMessage: 'No backup found on Google Drive.'),
        );
        return null;
      }

      state = const AsyncValue.data(SettingsState());
      return backupBytes;
    } on Exception catch (e) {
      debugPrint('Download backup failed: $e');
      state = AsyncValue.data(
        SettingsState(errorMessage: 'Failed to download backup: $e'),
      );
      return null;
    }
  }

  /// Step 2: Tries to restore the wallet using the downloaded data and password
  Future<bool> finishRestore(
    Uint8List backupBytes,
    String masterPassword,
  ) async {
    state = const AsyncValue.data(SettingsState(isProcessing: true));
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.restoreWalletFromBackupData(
        backupBytes: backupBytes,
        masterPassword: masterPassword,
      );

      ref.invalidate(walletViewModelProvider);

      state = const AsyncValue.data(
        SettingsState(
          successMessage: 'Restore successful! Your wallet has been updated.',
        ),
      );
      return true;
    } on Exception catch (e) {
      debugPrint('Restore failed: $e');
      state = const AsyncValue.data(
        SettingsState(
          errorMessage:
              'Restore failed. '
              'Please check your master password and try again.',
        ),
      );
      return false;
    }
  }

  Future<void> deleteBackup() async {
    state = const AsyncValue.data(SettingsState(isProcessing: true));
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.deleteBackupFromDrive();
      state = const AsyncValue.data(
        SettingsState(successMessage: 'Cloud backup deleted successfully!'),
      );
    } on Exception catch (e) {
      debugPrint('Delete backup failed: $e');
      state = AsyncValue.data(
        SettingsState(errorMessage: 'Delete backup failed: $e'),
      );
    }
  }
}
