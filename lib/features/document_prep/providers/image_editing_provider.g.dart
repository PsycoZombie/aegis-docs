// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_editing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageEditingViewModelHash() =>
    r'2663dd80e0114313320be506b188e5a615a06534';

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

abstract class _$ImageEditingViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ImageEditingState> {
  late final PickedFile? initialFile;

  FutureOr<ImageEditingState> build(PickedFile? initialFile);
}

/// See also [ImageEditingViewModel].
@ProviderFor(ImageEditingViewModel)
const imageEditingViewModelProvider = ImageEditingViewModelFamily();

/// See also [ImageEditingViewModel].
class ImageEditingViewModelFamily
    extends Family<AsyncValue<ImageEditingState>> {
  /// See also [ImageEditingViewModel].
  const ImageEditingViewModelFamily();

  /// See also [ImageEditingViewModel].
  ImageEditingViewModelProvider call(PickedFile? initialFile) {
    return ImageEditingViewModelProvider(initialFile);
  }

  @override
  ImageEditingViewModelProvider getProviderOverride(
    covariant ImageEditingViewModelProvider provider,
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
  String? get name => r'imageEditingViewModelProvider';
}

/// See also [ImageEditingViewModel].
class ImageEditingViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ImageEditingViewModel,
          ImageEditingState
        > {
  /// See also [ImageEditingViewModel].
  ImageEditingViewModelProvider(PickedFile? initialFile)
    : this._internal(
        () => ImageEditingViewModel()..initialFile = initialFile,
        from: imageEditingViewModelProvider,
        name: r'imageEditingViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageEditingViewModelHash,
        dependencies: ImageEditingViewModelFamily._dependencies,
        allTransitiveDependencies:
            ImageEditingViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  ImageEditingViewModelProvider._internal(
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
  FutureOr<ImageEditingState> runNotifierBuild(
    covariant ImageEditingViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(ImageEditingViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageEditingViewModelProvider._internal(
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
    ImageEditingViewModel,
    ImageEditingState
  >
  createElement() {
    return _ImageEditingViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageEditingViewModelProvider &&
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
mixin ImageEditingViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ImageEditingState> {
  /// The parameter `initialFile` of this provider.
  PickedFile? get initialFile;
}

class _ImageEditingViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ImageEditingViewModel,
          ImageEditingState
        >
    with ImageEditingViewModelRef {
  _ImageEditingViewModelProviderElement(super.provider);

  @override
  PickedFile? get initialFile =>
      (origin as ImageEditingViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
