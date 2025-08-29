// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeViewModelHash() => r'3f34fe1d3c1c5e2b712cb8a1fe89a000b0ec9e63';

/// A ViewModel for the home screen.
///
/// Manages the navigation state within the wallet's folder structure and
/// orchestrates user actions like creating, renaming,
/// deleting, and sharing items.
///
/// Copied from [HomeViewModel].
@ProviderFor(HomeViewModel)
final homeViewModelProvider =
    AutoDisposeNotifierProvider<HomeViewModel, HomeState>.internal(
      HomeViewModel.new,
      name: r'homeViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeViewModel = AutoDisposeNotifier<HomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
