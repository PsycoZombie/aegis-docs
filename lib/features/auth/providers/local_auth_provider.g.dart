// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'82398d9f38c720e4ddf6b218248f15089fd4f178';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$localAuthHash() => r'926f8592ce332d3dcc9e91b7c81dd53be9ca9ca0';

/// See also [LocalAuth].
@ProviderFor(LocalAuth)
final localAuthProvider =
    AutoDisposeNotifierProvider<LocalAuth, AuthState>.internal(
      LocalAuth.new,
      name: r'localAuthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localAuthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocalAuth = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
