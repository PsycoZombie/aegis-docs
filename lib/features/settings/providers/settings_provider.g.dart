// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsViewModelHash() => r'86412c76a004f8bb33ffbdfa771649e93fc5868c';

/// A ViewModel for the settings screen.
///
/// Manages the business logic for high-level operations like cloud backup,
/// restore, and deleting backups.
///
/// Copied from [SettingsViewModel].
@ProviderFor(SettingsViewModel)
final settingsViewModelProvider =
    AutoDisposeAsyncNotifierProvider<SettingsViewModel, SettingsState>.internal(
      SettingsViewModel.new,
      name: r'settingsViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsViewModel = AutoDisposeAsyncNotifier<SettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
