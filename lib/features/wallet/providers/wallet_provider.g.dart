// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allFoldersHash() => r'd9ad430657262cbc7f0316248cac93c605d581aa';

/// A provider that fetches a list of all
/// folder paths in the wallet recursively.
///
/// This is useful for UI elements like a "move to folder" dialog.
///
/// Copied from [allFolders].
@ProviderFor(allFolders)
final allFoldersProvider = AutoDisposeFutureProvider<List<String>>.internal(
  allFolders,
  name: r'allFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllFoldersRef = AutoDisposeFutureProviderRef<List<String>>;
String _$documentDetailHash() => r'c50fdffb8a6ee3026335216575f05b20fe2e89bc';

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

/// A provider that fetches and decrypts the content of a single document.
///
/// This is used by the document detail screen to display the file.
///
/// Copied from [documentDetail].
@ProviderFor(documentDetail)
const documentDetailProvider = DocumentDetailFamily();

/// A provider that fetches and decrypts the content of a single document.
///
/// This is used by the document detail screen to display the file.
///
/// Copied from [documentDetail].
class DocumentDetailFamily extends Family<AsyncValue<Uint8List?>> {
  /// A provider that fetches and decrypts the content of a single document.
  ///
  /// This is used by the document detail screen to display the file.
  ///
  /// Copied from [documentDetail].
  const DocumentDetailFamily();

  /// A provider that fetches and decrypts the content of a single document.
  ///
  /// This is used by the document detail screen to display the file.
  ///
  /// Copied from [documentDetail].
  DocumentDetailProvider call({
    required String fileName,
    required String? folderPath,
  }) {
    return DocumentDetailProvider(fileName: fileName, folderPath: folderPath);
  }

  @override
  DocumentDetailProvider getProviderOverride(
    covariant DocumentDetailProvider provider,
  ) {
    return call(fileName: provider.fileName, folderPath: provider.folderPath);
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

/// A provider that fetches and decrypts the content of a single document.
///
/// This is used by the document detail screen to display the file.
///
/// Copied from [documentDetail].
class DocumentDetailProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// A provider that fetches and decrypts the content of a single document.
  ///
  /// This is used by the document detail screen to display the file.
  ///
  /// Copied from [documentDetail].
  DocumentDetailProvider({
    required String fileName,
    required String? folderPath,
  }) : this._internal(
         (ref) => documentDetail(
           ref as DocumentDetailRef,
           fileName: fileName,
           folderPath: folderPath,
         ),
         from: documentDetailProvider,
         name: r'documentDetailProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$documentDetailHash,
         dependencies: DocumentDetailFamily._dependencies,
         allTransitiveDependencies:
             DocumentDetailFamily._allTransitiveDependencies,
         fileName: fileName,
         folderPath: folderPath,
       );

  DocumentDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileName,
    required this.folderPath,
  }) : super.internal();

  final String fileName;
  final String? folderPath;

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
        folderPath: folderPath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _DocumentDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentDetailProvider &&
        other.fileName == fileName &&
        other.folderPath == folderPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileName.hashCode);
    hash = _SystemHash.combine(hash, folderPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentDetailRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `fileName` of this provider.
  String get fileName;

  /// The parameter `folderPath` of this provider.
  String? get folderPath;
}

class _DocumentDetailProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with DocumentDetailRef {
  _DocumentDetailProviderElement(super.provider);

  @override
  String get fileName => (origin as DocumentDetailProvider).fileName;
  @override
  String? get folderPath => (origin as DocumentDetailProvider).folderPath;
}

String _$walletViewModelHash() => r'e6452d3796e5923e51d5f66809c2ec82689b04ae';

abstract class _$WalletViewModel
    extends BuildlessAutoDisposeAsyncNotifier<WalletState> {
  late final String? folderPath;

  FutureOr<WalletState> build(String? folderPath);
}

/// A ViewModel that provides the contents (folders and files) for a specific
/// directory within the secure wallet.
///
/// Copied from [WalletViewModel].
@ProviderFor(WalletViewModel)
const walletViewModelProvider = WalletViewModelFamily();

/// A ViewModel that provides the contents (folders and files) for a specific
/// directory within the secure wallet.
///
/// Copied from [WalletViewModel].
class WalletViewModelFamily extends Family<AsyncValue<WalletState>> {
  /// A ViewModel that provides the contents (folders and files) for a specific
  /// directory within the secure wallet.
  ///
  /// Copied from [WalletViewModel].
  const WalletViewModelFamily();

  /// A ViewModel that provides the contents (folders and files) for a specific
  /// directory within the secure wallet.
  ///
  /// Copied from [WalletViewModel].
  WalletViewModelProvider call(String? folderPath) {
    return WalletViewModelProvider(folderPath);
  }

  @override
  WalletViewModelProvider getProviderOverride(
    covariant WalletViewModelProvider provider,
  ) {
    return call(provider.folderPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletViewModelProvider';
}

/// A ViewModel that provides the contents (folders and files) for a specific
/// directory within the secure wallet.
///
/// Copied from [WalletViewModel].
class WalletViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WalletViewModel, WalletState> {
  /// A ViewModel that provides the contents (folders and files) for a specific
  /// directory within the secure wallet.
  ///
  /// Copied from [WalletViewModel].
  WalletViewModelProvider(String? folderPath)
    : this._internal(
        () => WalletViewModel()..folderPath = folderPath,
        from: walletViewModelProvider,
        name: r'walletViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$walletViewModelHash,
        dependencies: WalletViewModelFamily._dependencies,
        allTransitiveDependencies:
            WalletViewModelFamily._allTransitiveDependencies,
        folderPath: folderPath,
      );

  WalletViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderPath,
  }) : super.internal();

  final String? folderPath;

  @override
  FutureOr<WalletState> runNotifierBuild(covariant WalletViewModel notifier) {
    return notifier.build(folderPath);
  }

  @override
  Override overrideWith(WalletViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WalletViewModelProvider._internal(
        () => create()..folderPath = folderPath,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderPath: folderPath,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WalletViewModel, WalletState>
  createElement() {
    return _WalletViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletViewModelProvider && other.folderPath == folderPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletViewModelRef on AutoDisposeAsyncNotifierProviderRef<WalletState> {
  /// The parameter `folderPath` of this provider.
  String? get folderPath;
}

class _WalletViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<WalletViewModel, WalletState>
    with WalletViewModelRef {
  _WalletViewModelProviderElement(super.provider);

  @override
  String? get folderPath => (origin as WalletViewModelProvider).folderPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
