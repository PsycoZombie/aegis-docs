// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images_to_pdf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imagesToPdfViewModelHash() =>
    r'd1d432bde1de8a466a1bc5466833bbcb588ad307';

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
  late final List<PickedFileModel> initialFiles;

  FutureOr<ImagesToPdfState> build(List<PickedFileModel> initialFiles);
}

/// A ViewModel for the "Images to PDF" conversion feature.
///
/// Manages the list of selected images, their order, and the business logic
/// for converting them into a single PDF document.
///
/// Copied from [ImagesToPdfViewModel].
@ProviderFor(ImagesToPdfViewModel)
const imagesToPdfViewModelProvider = ImagesToPdfViewModelFamily();

/// A ViewModel for the "Images to PDF" conversion feature.
///
/// Manages the list of selected images, their order, and the business logic
/// for converting them into a single PDF document.
///
/// Copied from [ImagesToPdfViewModel].
class ImagesToPdfViewModelFamily extends Family<AsyncValue<ImagesToPdfState>> {
  /// A ViewModel for the "Images to PDF" conversion feature.
  ///
  /// Manages the list of selected images, their order, and the business logic
  /// for converting them into a single PDF document.
  ///
  /// Copied from [ImagesToPdfViewModel].
  const ImagesToPdfViewModelFamily();

  /// A ViewModel for the "Images to PDF" conversion feature.
  ///
  /// Manages the list of selected images, their order, and the business logic
  /// for converting them into a single PDF document.
  ///
  /// Copied from [ImagesToPdfViewModel].
  ImagesToPdfViewModelProvider call(List<PickedFileModel> initialFiles) {
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

/// A ViewModel for the "Images to PDF" conversion feature.
///
/// Manages the list of selected images, their order, and the business logic
/// for converting them into a single PDF document.
///
/// Copied from [ImagesToPdfViewModel].
class ImagesToPdfViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImagesToPdfViewModel,
          ImagesToPdfState
        > {
  /// A ViewModel for the "Images to PDF" conversion feature.
  ///
  /// Manages the list of selected images, their order, and the business logic
  /// for converting them into a single PDF document.
  ///
  /// Copied from [ImagesToPdfViewModel].
  ImagesToPdfViewModelProvider(List<PickedFileModel> initialFiles)
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

  final List<PickedFileModel> initialFiles;

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
  List<PickedFileModel> get initialFiles;
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
  List<PickedFileModel> get initialFiles =>
      (origin as ImagesToPdfViewModelProvider).initialFiles;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
