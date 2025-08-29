// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_compression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfCompressionViewModelHash() =>
    r'a53b91a63ca3659a0c1ed285cee75151b51f38b0';

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

abstract class _$PdfCompressionViewModel
    extends BuildlessAutoDisposeAsyncNotifier<PdfCompressionState> {
  late final PickedFileModel? initialFile;

  FutureOr<PdfCompressionState> build(PickedFileModel? initialFile);
}

/// A ViewModel for the native PDF compression feature.
///
/// Copied from [PdfCompressionViewModel].
@ProviderFor(PdfCompressionViewModel)
const pdfCompressionViewModelProvider = PdfCompressionViewModelFamily();

/// A ViewModel for the native PDF compression feature.
///
/// Copied from [PdfCompressionViewModel].
class PdfCompressionViewModelFamily
    extends Family<AsyncValue<PdfCompressionState>> {
  /// A ViewModel for the native PDF compression feature.
  ///
  /// Copied from [PdfCompressionViewModel].
  const PdfCompressionViewModelFamily();

  /// A ViewModel for the native PDF compression feature.
  ///
  /// Copied from [PdfCompressionViewModel].
  PdfCompressionViewModelProvider call(PickedFileModel? initialFile) {
    return PdfCompressionViewModelProvider(initialFile);
  }

  @override
  PdfCompressionViewModelProvider getProviderOverride(
    covariant PdfCompressionViewModelProvider provider,
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
  String? get name => r'pdfCompressionViewModelProvider';
}

/// A ViewModel for the native PDF compression feature.
///
/// Copied from [PdfCompressionViewModel].
class PdfCompressionViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PdfCompressionViewModel,
          PdfCompressionState
        > {
  /// A ViewModel for the native PDF compression feature.
  ///
  /// Copied from [PdfCompressionViewModel].
  PdfCompressionViewModelProvider(PickedFileModel? initialFile)
    : this._internal(
        () => PdfCompressionViewModel()..initialFile = initialFile,
        from: pdfCompressionViewModelProvider,
        name: r'pdfCompressionViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pdfCompressionViewModelHash,
        dependencies: PdfCompressionViewModelFamily._dependencies,
        allTransitiveDependencies:
            PdfCompressionViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  PdfCompressionViewModelProvider._internal(
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
  FutureOr<PdfCompressionState> runNotifierBuild(
    covariant PdfCompressionViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(PdfCompressionViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PdfCompressionViewModelProvider._internal(
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
    PdfCompressionViewModel,
    PdfCompressionState
  >
  createElement() {
    return _PdfCompressionViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PdfCompressionViewModelProvider &&
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
mixin PdfCompressionViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<PdfCompressionState> {
  /// The parameter `initialFile` of this provider.
  PickedFileModel? get initialFile;
}

class _PdfCompressionViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PdfCompressionViewModel,
          PdfCompressionState
        >
    with PdfCompressionViewModelRef {
  _PdfCompressionViewModelProviderElement(super.provider);

  @override
  PickedFileModel? get initialFile =>
      (origin as PdfCompressionViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
