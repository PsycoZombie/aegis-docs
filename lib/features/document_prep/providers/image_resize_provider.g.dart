// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_resize_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageResizeViewModelHash() =>
    r'2080e0f3b812f08797341132b056f000979f4866';

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

abstract class _$ImageResizeViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ResizeState> {
  late final PickedFile? initialFile;

  FutureOr<ResizeState> build(PickedFile? initialFile);
}

/// See also [ImageResizeViewModel].
@ProviderFor(ImageResizeViewModel)
const imageResizeViewModelProvider = ImageResizeViewModelFamily();

/// See also [ImageResizeViewModel].
class ImageResizeViewModelFamily extends Family<AsyncValue<ResizeState>> {
  /// See also [ImageResizeViewModel].
  const ImageResizeViewModelFamily();

  /// See also [ImageResizeViewModel].
  ImageResizeViewModelProvider call(PickedFile? initialFile) {
    return ImageResizeViewModelProvider(initialFile);
  }

  @override
  ImageResizeViewModelProvider getProviderOverride(
    covariant ImageResizeViewModelProvider provider,
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
  String? get name => r'imageResizeViewModelProvider';
}

/// See also [ImageResizeViewModel].
class ImageResizeViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImageResizeViewModel,
          ResizeState
        > {
  /// See also [ImageResizeViewModel].
  ImageResizeViewModelProvider(PickedFile? initialFile)
    : this._internal(
        () => ImageResizeViewModel()..initialFile = initialFile,
        from: imageResizeViewModelProvider,
        name: r'imageResizeViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageResizeViewModelHash,
        dependencies: ImageResizeViewModelFamily._dependencies,
        allTransitiveDependencies:
            ImageResizeViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  ImageResizeViewModelProvider._internal(
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
    covariant ImageResizeViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(ImageResizeViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageResizeViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ImageResizeViewModel, ResizeState>
  createElement() {
    return _ImageResizeViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageResizeViewModelProvider &&
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
mixin ImageResizeViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ResizeState> {
  /// The parameter `initialFile` of this provider.
  PickedFile? get initialFile;
}

class _ImageResizeViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ImageResizeViewModel,
          ResizeState
        >
    with ImageResizeViewModelRef {
  _ImageResizeViewModelProviderElement(super.provider);

  @override
  PickedFile? get initialFile =>
      (origin as ImageResizeViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
