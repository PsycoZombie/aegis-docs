// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_security_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfSecurityViewModelHash() =>
    r'415d42fa3ea3e49e01e8b26fd806be7f3271d9e5';

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

abstract class _$PdfSecurityViewModel
    extends BuildlessAutoDisposeAsyncNotifier<PdfSecurityState> {
  late final PickedFileModel? initialFile;

  FutureOr<PdfSecurityState> build(PickedFileModel? initialFile);
}

/// A ViewModel for the PDF security feature.
///
/// Manages the state and business logic for adding, removing, or changing
/// a PDF's password protection.
///
/// Copied from [PdfSecurityViewModel].
@ProviderFor(PdfSecurityViewModel)
const pdfSecurityViewModelProvider = PdfSecurityViewModelFamily();

/// A ViewModel for the PDF security feature.
///
/// Manages the state and business logic for adding, removing, or changing
/// a PDF's password protection.
///
/// Copied from [PdfSecurityViewModel].
class PdfSecurityViewModelFamily extends Family<AsyncValue<PdfSecurityState>> {
  /// A ViewModel for the PDF security feature.
  ///
  /// Manages the state and business logic for adding, removing, or changing
  /// a PDF's password protection.
  ///
  /// Copied from [PdfSecurityViewModel].
  const PdfSecurityViewModelFamily();

  /// A ViewModel for the PDF security feature.
  ///
  /// Manages the state and business logic for adding, removing, or changing
  /// a PDF's password protection.
  ///
  /// Copied from [PdfSecurityViewModel].
  PdfSecurityViewModelProvider call(PickedFileModel? initialFile) {
    return PdfSecurityViewModelProvider(initialFile);
  }

  @override
  PdfSecurityViewModelProvider getProviderOverride(
    covariant PdfSecurityViewModelProvider provider,
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
  String? get name => r'pdfSecurityViewModelProvider';
}

/// A ViewModel for the PDF security feature.
///
/// Manages the state and business logic for adding, removing, or changing
/// a PDF's password protection.
///
/// Copied from [PdfSecurityViewModel].
class PdfSecurityViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PdfSecurityViewModel,
          PdfSecurityState
        > {
  /// A ViewModel for the PDF security feature.
  ///
  /// Manages the state and business logic for adding, removing, or changing
  /// a PDF's password protection.
  ///
  /// Copied from [PdfSecurityViewModel].
  PdfSecurityViewModelProvider(PickedFileModel? initialFile)
    : this._internal(
        () => PdfSecurityViewModel()..initialFile = initialFile,
        from: pdfSecurityViewModelProvider,
        name: r'pdfSecurityViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pdfSecurityViewModelHash,
        dependencies: PdfSecurityViewModelFamily._dependencies,
        allTransitiveDependencies:
            PdfSecurityViewModelFamily._allTransitiveDependencies,
        initialFile: initialFile,
      );

  PdfSecurityViewModelProvider._internal(
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
  FutureOr<PdfSecurityState> runNotifierBuild(
    covariant PdfSecurityViewModel notifier,
  ) {
    return notifier.build(initialFile);
  }

  @override
  Override overrideWith(PdfSecurityViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PdfSecurityViewModelProvider._internal(
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
    PdfSecurityViewModel,
    PdfSecurityState
  >
  createElement() {
    return _PdfSecurityViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PdfSecurityViewModelProvider &&
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
mixin PdfSecurityViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<PdfSecurityState> {
  /// The parameter `initialFile` of this provider.
  PickedFileModel? get initialFile;
}

class _PdfSecurityViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PdfSecurityViewModel,
          PdfSecurityState
        >
    with PdfSecurityViewModelRef {
  _PdfSecurityViewModelProviderElement(super.provider);

  @override
  PickedFileModel? get initialFile =>
      (origin as PdfSecurityViewModelProvider).initialFile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
