// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images_to_pdf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imagesToPdfViewModelHash() =>
    r'571da921a99cba98abec63f36677b686f9e3d227';

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

abstract class _$ImagesToPdfViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ImagesToPdfState> {
  late final List<PickedFile> initialFiles;

  FutureOr<ImagesToPdfState> build(List<PickedFile> initialFiles);
}

/// See also [ImagesToPdfViewModel].
@ProviderFor(ImagesToPdfViewModel)
const imagesToPdfViewModelProvider = ImagesToPdfViewModelFamily();

/// See also [ImagesToPdfViewModel].
class ImagesToPdfViewModelFamily extends Family<AsyncValue<ImagesToPdfState>> {
  /// See also [ImagesToPdfViewModel].
  const ImagesToPdfViewModelFamily();

  /// See also [ImagesToPdfViewModel].
  ImagesToPdfViewModelProvider call(List<PickedFile> initialFiles) {
    return ImagesToPdfViewModelProvider(initialFiles);
  }

  @override
  ImagesToPdfViewModelProvider getProviderOverride(
    covariant ImagesToPdfViewModelProvider provider,
  ) {
    return call(provider.initialFiles);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imagesToPdfViewModelProvider';
}

/// See also [ImagesToPdfViewModel].
class ImagesToPdfViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImagesToPdfViewModel,
          ImagesToPdfState
        > {
  /// See also [ImagesToPdfViewModel].
  ImagesToPdfViewModelProvider(List<PickedFile> initialFiles)
    : this._internal(
        () => ImagesToPdfViewModel()..initialFiles = initialFiles,
        from: imagesToPdfViewModelProvider,
        name: r'imagesToPdfViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imagesToPdfViewModelHash,
        dependencies: ImagesToPdfViewModelFamily._dependencies,
        allTransitiveDependencies:
            ImagesToPdfViewModelFamily._allTransitiveDependencies,
        initialFiles: initialFiles,
      );

  ImagesToPdfViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialFiles,
  }) : super.internal();

  final List<PickedFile> initialFiles;

  @override
  FutureOr<ImagesToPdfState> runNotifierBuild(
    covariant ImagesToPdfViewModel notifier,
  ) {
    return notifier.build(initialFiles);
  }

  @override
  Override overrideWith(ImagesToPdfViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImagesToPdfViewModelProvider._internal(
        () => create()..initialFiles = initialFiles,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialFiles: initialFiles,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ImagesToPdfViewModel,
    ImagesToPdfState
  >
  createElement() {
    return _ImagesToPdfViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagesToPdfViewModelProvider &&
        other.initialFiles == initialFiles;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialFiles.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagesToPdfViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ImagesToPdfState> {
  /// The parameter `initialFiles` of this provider.
  List<PickedFile> get initialFiles;
}

class _ImagesToPdfViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ImagesToPdfViewModel,
          ImagesToPdfState
        >
    with ImagesToPdfViewModelRef {
  _ImagesToPdfViewModelProviderElement(super.provider);

  @override
  List<PickedFile> get initialFiles =>
      (origin as ImagesToPdfViewModelProvider).initialFiles;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
