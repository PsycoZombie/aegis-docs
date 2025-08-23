// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cleanupDurationSettingHash() =>
    r'ff09c854c28558eb8adc2407f7395fddf17e53da';

/// A provider that manages the state of the cleanup duration setting.
///
/// It asynchronously loads the initial value from storage and provides a method
/// to update and persist the new value.
///
/// Copied from [CleanupDurationSetting].
@ProviderFor(CleanupDurationSetting)
final cleanupDurationSettingProvider =
    AutoDisposeAsyncNotifierProvider<
      CleanupDurationSetting,
      CleanupDuration
    >.internal(
      CleanupDurationSetting.new,
      name: r'cleanupDurationSettingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cleanupDurationSettingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CleanupDurationSetting = AutoDisposeAsyncNotifier<CleanupDuration>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
