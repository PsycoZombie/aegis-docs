// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_resize_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageResizeViewModelHash() =>
    r'8bf04814a46edfa3f40a1adffe006add466c8cbd';

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
  late final PickedFileModel? initialFile;

  FutureOr<ResizeState> build(PickedFileModel? initialFile);
}

/// A ViewModel for the image resizing feature.
///
/// Manages the state and business logic for resizing
/// an image to new dimensions,
/// with support for aspect ratio locking and presets.
///
/// Copied from [ImageResizeViewModel].
@ProviderFor(ImageResizeViewModel)
const imageResizeViewModelProvider = ImageResizeViewModelFamily();

/// A ViewModel for the image resizing feature.
///
/// Manages the state and business logic for resizing
/// an image to new dimensions,
/// with support for aspect ratio locking and presets.
///
/// Copied from [ImageResizeViewModel].
class ImageResizeViewModelFamily extends Family<AsyncValue<ResizeState>> {
  /// A ViewModel for the image resizing feature.
  ///
  /// Manages the state and business logic for resizing
  /// an image to new dimensions,
  /// with support for aspect ratio locking and presets.
  ///
  /// Copied from [ImageResizeViewModel].
  const ImageResizeViewModelFamily();

  /// A ViewModel for the image resizing feature.
  ///
  /// Manages the state and business logic for resizing
  /// an image to new dimensions,
  /// with support for aspect ratio locking and presets.
  ///
  /// Copied from [ImageResizeViewModel].
  ImageResizeViewModelProvider call(PickedFileModel? initialFile) {
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

/// A ViewModel for the image resizing feature.
///
/// Manages the state and business logic for resizing
/// an image to new dimensions,
/// with support for aspect ratio locking and presets.
///
/// Copied from [ImageResizeViewModel].
class ImageResizeViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImageResizeViewModel,
          ResizeState
        > {
  /// A ViewModel for the image resizing feature.
  ///
  /// Manages the state and business logic for resizing
  /// an image to new dimensions,
  /// with support for aspect ratio locking and presets.
  ///
  /// Copied from [ImageResizeViewModel].
  ImageResizeViewModelProvider(PickedFileModel? initialFile)
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

  final PickedFileModel? initialFile;

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
  PickedFileModel? get initialFile;
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
  PickedFileModel? get initialFile =>
      (origin as ImageResizeViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
