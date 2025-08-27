// import 'dart:io';

// import 'package:aegis_docs/data/repositories/document_repository.dart';
// import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'settings_provider.g.dart';

// /// Represents the possible outcomes of a backup deletion attempt.
// // ignore: public_member_api_docs
// enum DeleteBackupResult { success, notFound, error }

// /// Represents the state for the settings screen.
// /// Note: This class is currently empty because loading and error states are
// /// handled by the AsyncValue wrapper from Riverpod. It can be extended later
// /// if more specific state properties are needed.
// @immutable
// class SettingsState extends Equatable {
//   /// Creates an instance of the settings state.
//   const SettingsState();

//   @override
//   List<Object?> get props => [];
// }

// /// A ViewModel for the settings screen.
// ///
// /// Manages the business logic for high-level operations like cloud backup,
// /// restore, and deleting backups.
// @riverpod
// class SettingsViewModel extends _$SettingsViewModel {
//   @override
//   Future<SettingsState> build() async {
//     return const SettingsState();
//   }

//   /// Backs up the entire user wallet to the cloud.
//   /// Returns `true` on success, `false` on failure.
//   Future<bool> backupWallet(String masterPassword) async {
//     state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
//     state = await AsyncValue.guard(() async {
//       final repo = await ref.read(documentRepositoryProvider.future);
//       await repo.backupWalletToDrive(masterPassword);
//       return const SettingsState();
//     });
//     return !state.hasError;
//   }

//   /// Downloads the latest wallet backup from the cloud.
//   /// Returns the backup data as bytes, or `null` if
//   /// no backup is found or an error occurs.
//   Future<File?> downloadBackup() async {
//     state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
//     try {
//       final repo = await ref.read(documentRepositoryProvider.future);
//       final backupBytes = await repo.downloadBackupFromDrive();
//       // Reset to a non-loading, non-error state after completion.
//       state = const AsyncData(SettingsState());
//       return backupBytes;
//     } on Exception catch (e) {
//       state = AsyncError(e, StackTrace.current);
//       return null;
//     }
//   }

//   /// Completes the restore process using the
//   /// downloaded backup data and master password.
//   /// Returns `true` on success, `false` on failure (e.g., wrong password).
//   Future<bool> finishRestore(
//     File backupBytes,
//     String masterPassword,
//   ) async {
//     state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
//     state = await AsyncValue.guard(() async {
//       final repo = await ref.read(documentRepositoryProvider.future);
//       await repo.restoreWalletFromBackupData(
//         backupBytes: backupBytes,
//         masterPassword: masterPassword,
//       );
//       // Invalidate all wallet providers to force a full refresh of the UI.
//       ref.invalidate(walletViewModelProvider);
//       return const SettingsState();
//     });
//     return !state.hasError;
//   }

//   /// Deletes the wallet backup from the cloud.
//   /// Returns a [DeleteBackupResult] to indicate the outcome.
//   Future<DeleteBackupResult> deleteBackup() async {
//     state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
//     try {
//       final repo = await ref.read(documentRepositoryProvider.future);
//       final result = await repo.deleteBackupFromDrive();

//       state = const AsyncData(SettingsState()); // Reset to idle state

//       switch (result) {
//         case true:
//           return DeleteBackupResult.success;
//         case null:
//           return DeleteBackupResult.notFound;
//         default:
//           return DeleteBackupResult.error;
//       }
//     } on Exception catch (e, st) {
//       state = AsyncError(e, st);
//       return DeleteBackupResult.error;
//     }
//   }
// }

import 'dart:io';

import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

/// Represents the possible outcomes of a backup deletion attempt.
// ignore: public_member_api_docs
enum DeleteBackupResult { success, notFound, error }

/// Represents the state for the settings screen.
@immutable
class SettingsState extends Equatable {
  /// Creates an instance of the settings state.
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// A ViewModel for the settings screen.
///
/// Manages the business logic for high-level operations like cloud backup,
/// restore, and deleting backups.
@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  Future<SettingsState> build() async {
    return const SettingsState();
  }

  /// Backs up the entire user wallet to the cloud.
  /// Returns `true` on success, `false` on failure.
  Future<bool> backupWallet(String masterPassword) async {
    state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.backupWalletToDrive(masterPassword);
      return const SettingsState();
    });
    return !state.hasError;
  }

  /// Downloads the latest wallet backup from the cloud to a temporary file.
  /// Returns the backup as a [File], or `null` if not found or an error occurs.
  Future<File?> downloadBackup() async {
    state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final backupFile = await repo.downloadBackupFromDrive();
      // Reset to a non-loading, non-error state after completion.
      state = const AsyncData(SettingsState());
      return backupFile;
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Completes the restore process using the
  /// downloaded backup file and master password.
  /// Returns `true` on success, `false` on failure (e.g., wrong password).
  Future<bool> finishRestore(
    File backupFile,
    String masterPassword,
  ) async {
    state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.restoreWalletFromBackupData(
        backupFile: backupFile,
        masterPassword: masterPassword,
      );
      // Invalidate all wallet providers to force a full refresh of the UI.
      ref.invalidate(walletViewModelProvider);
      return const SettingsState();
    });
    return !state.hasError;
  }

  /// Deletes the wallet backup from the cloud.
  /// Returns a [DeleteBackupResult] to indicate the outcome.
  Future<DeleteBackupResult> deleteBackup() async {
    state = const AsyncLoading<SettingsState>().copyWithPrevious(state);
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final result = await repo.deleteBackupFromDrive();

      state = const AsyncData(SettingsState()); // Reset to idle state

      switch (result) {
        case true:
          return DeleteBackupResult.success;
        case null:
          return DeleteBackupResult.notFound;
        default:
          return DeleteBackupResult.error;
      }
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
      return DeleteBackupResult.error;
    }
  }
}
