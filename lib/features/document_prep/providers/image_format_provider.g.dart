// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_format_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageFormatViewModelHash() =>
    r'68ad66bfb3a85d3fa5ecd749949ed4f823e1503f';

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

abstract class _$ImageFormatViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ImageFormatState> {
  late final PickedFileModel? initialFile;

  FutureOr<ImageFormatState> build(PickedFileModel? initialFile);
}

/// A ViewModel for the image format conversion feature.
///
/// Manages the state and business logic for changing an image's file type
/// (e.g., from JPG to PNG).
///
/// Copied from [ImageFormatViewModel].
@ProviderFor(ImageFormatViewModel)
const imageFormatViewModelProvider = ImageFormatViewModelFamily();

/// A ViewModel for the image format conversion feature.
///
/// Manages the state and business logic for changing an image's file type
/// (e.g., from JPG to PNG).
///
/// Copied from [ImageFormatViewModel].
class ImageFormatViewModelFamily extends Family<AsyncValue<ImageFormatState>> {
  /// A ViewModel for the image format conversion feature.
  ///
  /// Manages the state and business logic for changing an image's file type
  /// (e.g., from JPG to PNG).
  ///
  /// Copied from [ImageFormatViewModel].
  const ImageFormatViewModelFamily();

  /// A ViewModel for the image format conversion feature.
  ///
  /// Manages the state and business logic for changing an image's file type
  /// (e.g., from JPG to PNG).
  ///
  /// Copied from [ImageFormatViewModel].
  ImageFormatViewModelProvider call(PickedFileModel? initialFile) {
    return ImageFormatViewModelProvider(initialFile);
  }

  @override
  ImageFormatViewModelProvider getProviderOverride(
    covariant ImageFormatViewModelProvider provider,
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
  String? get name => r'imageFormatViewModelProvider';
}

/// A ViewModel for the image format conversion feature.
///
/// Manages the state and business logic for changing an image's file type
/// (e.g., from JPG to PNG).
///
/// Copied from [ImageFormatViewModel].
class ImageFormatViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImageFormatViewModel,
          ImageFormatState
        > {
  /// A ViewModel for the image format conversion feature.
  ///
  /// Manages the state and business logic for changing an image's file type
  /// (e.g., from JPG to PNG).
  ///
  /// Copied from [ImageFormatViewModel].
  ImageFormatViewModelProvider(PickedFileModel? initialFile)
    : this._internal(
        () => ImageFormatViewModel()..initialFile = initialFile,
        from: imageFormatViewModelProvider,
        name: r'imageFormatViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageFormatViewModelHash,
        dependencies: ImageFormatViewModelFamily._dependencies,
        allTransitiveDependencies:
            ImageFormatViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  ImageFormatViewModelProvider._internal(
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
  FutureOr<ImageFormatState> runNotifierBuild(
    covariant ImageFormatViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(ImageFormatViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageFormatViewModelProvider._internal(
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
    ImageFormatViewModel,
    ImageFormatState
  >
  createElement() {
    return _ImageFormatViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageFormatViewModelProvider &&
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
mixin ImageFormatViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ImageFormatState> {
  /// The parameter `initialFile` of this provider.
  PickedFileModel? get initialFile;
}

class _ImageFormatViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ImageFormatViewModel,
          ImageFormatState
        >
    with ImageFormatViewModelRef {
  _ImageFormatViewModelProviderElement(super.provider);

  @override
  PickedFileModel? get initialFile =>
      (origin as ImageFormatViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
