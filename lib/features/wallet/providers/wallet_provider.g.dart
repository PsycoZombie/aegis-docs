// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentDetailHash() => r'dbd2c46b3a3d85ba00cc38378d19c9d88958a514';

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

/// See also [documentDetail].
@ProviderFor(documentDetail)
const documentDetailProvider = DocumentDetailFamily();

/// See also [documentDetail].
class DocumentDetailFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [documentDetail].
  const DocumentDetailFamily();

  /// See also [documentDetail].
  DocumentDetailProvider call({required String fileName}) {
    return DocumentDetailProvider(fileName: fileName);
  }

  @override
  DocumentDetailProvider getProviderOverride(
    covariant DocumentDetailProvider provider,
  ) {
    return call(fileName: provider.fileName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentDetailProvider';
}

/// See also [documentDetail].
class DocumentDetailProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// See also [documentDetail].
  DocumentDetailProvider({required String fileName})
    : this._internal(
        (ref) => documentDetail(ref as DocumentDetailRef, fileName: fileName),
        from: documentDetailProvider,
        name: r'documentDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentDetailHash,
        dependencies: DocumentDetailFamily._dependencies,
        allTransitiveDependencies:
            DocumentDetailFamily._allTransitiveDependencies,
        fileName: fileName,
      );

  DocumentDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileName,
  }) : super.internal();

  final String fileName;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(DocumentDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentDetailProvider._internal(
        (ref) => create(ref as DocumentDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileName: fileName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _DocumentDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentDetailProvider && other.fileName == fileName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentDetailRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `fileName` of this provider.
  String get fileName;
}

class _DocumentDetailProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with DocumentDetailRef {
  _DocumentDetailProviderElement(super.provider);

  @override
  String get fileName => (origin as DocumentDetailProvider).fileName;
}

String _$walletHash() => r'56cff6cf8206e60b2ca84d279748588d14b82a2b';

/// See also [Wallet].
@ProviderFor(Wallet)
final walletProvider =
    AutoDisposeAsyncNotifierProvider<Wallet, List<File>>.internal(
      Wallet.new,
      name: r'walletProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walletHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Wallet = AutoDisposeAsyncNotifier<List<File>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
