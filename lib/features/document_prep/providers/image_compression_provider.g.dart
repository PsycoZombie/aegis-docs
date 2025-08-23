// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_compression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageCompressionViewModelHash() =>
    r'e2e112483879062f9dee8a8dae17fed8a3a841dc';

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

abstract class _$ImageCompressionViewModel
    extends BuildlessAutoDisposeAsyncNotifier<CompressionState> {
  late final PickedFileModel? initialFile;

  FutureOr<CompressionState> build(PickedFileModel? initialFile);
}

/// A ViewModel (using Riverpod) for the image compression feature.
///
/// This provider manages the state ([CompressionState]) and business logic for
/// compressing an image to a target size.
///
/// Copied from [ImageCompressionViewModel].
@ProviderFor(ImageCompressionViewModel)
const imageCompressionViewModelProvider = ImageCompressionViewModelFamily();

/// A ViewModel (using Riverpod) for the image compression feature.
///
/// This provider manages the state ([CompressionState]) and business logic for
/// compressing an image to a target size.
///
/// Copied from [ImageCompressionViewModel].
class ImageCompressionViewModelFamily
    extends Family<AsyncValue<CompressionState>> {
  /// A ViewModel (using Riverpod) for the image compression feature.
  ///
  /// This provider manages the state ([CompressionState]) and business logic for
  /// compressing an image to a target size.
  ///
  /// Copied from [ImageCompressionViewModel].
  const ImageCompressionViewModelFamily();

  /// A ViewModel (using Riverpod) for the image compression feature.
  ///
  /// This provider manages the state ([CompressionState]) and business logic for
  /// compressing an image to a target size.
  ///
  /// Copied from [ImageCompressionViewModel].
  ImageCompressionViewModelProvider call(PickedFileModel? initialFile) {
    return ImageCompressionViewModelProvider(initialFile);
  }

  @override
  ImageCompressionViewModelProvider getProviderOverride(
    covariant ImageCompressionViewModelProvider provider,
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
  String? get name => r'imageCompressionViewModelProvider';
}

/// A ViewModel (using Riverpod) for the image compression feature.
///
/// This provider manages the state ([CompressionState]) and business logic for
/// compressing an image to a target size.
///
/// Copied from [ImageCompressionViewModel].
class ImageCompressionViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImageCompressionViewModel,
          CompressionState
        > {
  /// A ViewModel (using Riverpod) for the image compression feature.
  ///
  /// This provider manages the state ([CompressionState]) and business logic for
  /// compressing an image to a target size.
  ///
  /// Copied from [ImageCompressionViewModel].
  ImageCompressionViewModelProvider(PickedFileModel? initialFile)
    : this._internal(
        () => ImageCompressionViewModel()..initialFile = initialFile,
        from: imageCompressionViewModelProvider,
        name: r'imageCompressionViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageCompressionViewModelHash,
        dependencies: ImageCompressionViewModelFamily._dependencies,
        allTransitiveDependencies:
            ImageCompressionViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  ImageCompressionViewModelProvider._internal(
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
  FutureOr<CompressionState> runNotifierBuild(
    covariant ImageCompressionViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(ImageCompressionViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageCompressionViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<
    ImageCompressionViewModel,
    CompressionState
  >
  createElement() {
    return _ImageCompressionViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageCompressionViewModelProvider &&
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
mixin ImageCompressionViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<CompressionState> {
  /// The parameter `initialFile` of this provider.
  PickedFileModel? get initialFile;
}

class _ImageCompressionViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ImageCompressionViewModel,
          CompressionState
        >
    with ImageCompressionViewModelRef {
  _ImageCompressionViewModelProviderElement(super.provider);

  @override
  PickedFileModel? get initialFile =>
      (origin as ImageCompressionViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
