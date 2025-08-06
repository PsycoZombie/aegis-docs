// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resize_tool_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resizeToolViewModelHash() =>
    r'59217e7427c272cb233170de9d19031a3a4feb37';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ResizeToolViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ResizeState> {
  late final PickedFile? initialFile;

  FutureOr<ResizeState> build(PickedFile? initialFile);
}

/// See also [ResizeToolViewModel].
@ProviderFor(ResizeToolViewModel)
const resizeToolViewModelProvider = ResizeToolViewModelFamily();

/// See also [ResizeToolViewModel].
class ResizeToolViewModelFamily extends Family<AsyncValue<ResizeState>> {
  /// See also [ResizeToolViewModel].
  const ResizeToolViewModelFamily();

  /// See also [ResizeToolViewModel].
  ResizeToolViewModelProvider call(PickedFile? initialFile) {
    return ResizeToolViewModelProvider(initialFile);
  }

  @override
  ResizeToolViewModelProvider getProviderOverride(
    covariant ResizeToolViewModelProvider provider,
  ) {
    return call(provider.initialFile);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'resizeToolViewModelProvider';
}

/// See also [ResizeToolViewModel].
class ResizeToolViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ResizeToolViewModel, ResizeState> {
  /// See also [ResizeToolViewModel].
  ResizeToolViewModelProvider(PickedFile? initialFile)
    : this._internal(
        () => ResizeToolViewModel()..initialFile = initialFile,
        from: resizeToolViewModelProvider,
        name: r'resizeToolViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$resizeToolViewModelHash,
        dependencies: ResizeToolViewModelFamily._dependencies,
        allTransitiveDependencies:
            ResizeToolViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  ResizeToolViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialFile,
  }) : super.internal();

  final PickedFile? initialFile;

  @override
  FutureOr<ResizeState> runNotifierBuild(
    covariant ResizeToolViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(ResizeToolViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ResizeToolViewModelProvider._internal(
        () => create()..initialFile = initialFile,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialFile: initialFile,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ResizeToolViewModel, ResizeState>
  createElement() {
    return _ResizeToolViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResizeToolViewModelProvider &&
        other.initialFile == initialFile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialFile.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResizeToolViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ResizeState> {
  /// The parameter `initialFile` of this provider.
  PickedFile? get initialFile;
}

class _ResizeToolViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ResizeToolViewModel,
          ResizeState
        >
    with ResizeToolViewModelRef {
  _ResizeToolViewModelProviderElement(super.provider);

  @override
  PickedFile? get initialFile =>
      (origin as ResizeToolViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
