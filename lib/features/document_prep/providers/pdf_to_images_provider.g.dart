// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_to_images_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfToImagesViewModelHash() =>
    r'45dda7ed5b55e49970d7258eb586a8d88de45d29';

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

abstract class _$PdfToImagesViewModel
    extends BuildlessAutoDisposeAsyncNotifier<PdfToImagesState> {
  late final PickedFile? initialFile;

  FutureOr<PdfToImagesState> build(PickedFile? initialFile);
}

/// See also [PdfToImagesViewModel].
@ProviderFor(PdfToImagesViewModel)
const pdfToImagesViewModelProvider = PdfToImagesViewModelFamily();

/// See also [PdfToImagesViewModel].
class PdfToImagesViewModelFamily extends Family<AsyncValue<PdfToImagesState>> {
  /// See also [PdfToImagesViewModel].
  const PdfToImagesViewModelFamily();

  /// See also [PdfToImagesViewModel].
  PdfToImagesViewModelProvider call(PickedFile? initialFile) {
    return PdfToImagesViewModelProvider(initialFile);
  }

  @override
  PdfToImagesViewModelProvider getProviderOverride(
    covariant PdfToImagesViewModelProvider provider,
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
  String? get name => r'pdfToImagesViewModelProvider';
}

/// See also [PdfToImagesViewModel].
class PdfToImagesViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PdfToImagesViewModel,
          PdfToImagesState
        > {
  /// See also [PdfToImagesViewModel].
  PdfToImagesViewModelProvider(PickedFile? initialFile)
    : this._internal(
        () => PdfToImagesViewModel()..initialFile = initialFile,
        from: pdfToImagesViewModelProvider,
        name: r'pdfToImagesViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pdfToImagesViewModelHash,
        dependencies: PdfToImagesViewModelFamily._dependencies,
        allTransitiveDependencies:
            PdfToImagesViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  PdfToImagesViewModelProvider._internal(
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
  FutureOr<PdfToImagesState> runNotifierBuild(
    covariant PdfToImagesViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(PdfToImagesViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PdfToImagesViewModelProvider._internal(
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
    PdfToImagesViewModel,
    PdfToImagesState
  >
  createElement() {
    return _PdfToImagesViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PdfToImagesViewModelProvider &&
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
mixin PdfToImagesViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<PdfToImagesState> {
  /// The parameter `initialFile` of this provider.
  PickedFile? get initialFile;
}

class _PdfToImagesViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PdfToImagesViewModel,
          PdfToImagesState
        >
    with PdfToImagesViewModelRef {
  _PdfToImagesViewModelProviderElement(super.provider);

  @override
  PickedFile? get initialFile =>
      (origin as PdfToImagesViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
