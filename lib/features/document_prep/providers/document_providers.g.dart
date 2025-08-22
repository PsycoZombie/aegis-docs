// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filePickerServiceHash() => r'1062b982f7372ea0345e67a17f94b83331fda549';

/// See also [filePickerService].
@ProviderFor(filePickerService)
final filePickerServiceProvider = Provider<FilePickerService>.internal(
  filePickerService,
  name: r'filePickerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filePickerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilePickerServiceRef = ProviderRef<FilePickerService>;
String _$fileStorageServiceHash() =>
    r'83f564e7d4f115c3d6755bec522f9c0a1701f9aa';

/// See also [fileStorageService].
@ProviderFor(fileStorageService)
final fileStorageServiceProvider = Provider<FileStorageService>.internal(
  fileStorageService,
  name: r'fileStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fileStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FileStorageServiceRef = ProviderRef<FileStorageService>;
String _$cloudStorageServiceHash() =>
    r'726eef7c302672195ab6609760f7b5b72b6fcd8a';

/// See also [cloudStorageService].
@ProviderFor(cloudStorageService)
final cloudStorageServiceProvider =
    AutoDisposeProvider<CloudStorageService>.internal(
      cloudStorageService,
      name: r'cloudStorageServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cloudStorageServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CloudStorageServiceRef = AutoDisposeProviderRef<CloudStorageService>;
String _$imageProcessorHash() => r'9ff24df7ba683b672a40b2ef34542876e8c02d15';

/// See also [imageProcessor].
@ProviderFor(imageProcessor)
final imageProcessorProvider = Provider<ImageProcessor>.internal(
  imageProcessor,
  name: r'imageProcessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageProcessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageProcessorRef = ProviderRef<ImageProcessor>;
String _$pdfProcessorHash() => r'0c79e201a665c5864ff7c69031b96b3a8a71cc32';

/// See also [pdfProcessor].
@ProviderFor(pdfProcessor)
final pdfProcessorProvider = Provider<PdfProcessor>.internal(
  pdfProcessor,
  name: r'pdfProcessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pdfProcessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PdfProcessorRef = ProviderRef<PdfProcessor>;
String _$nativeCompressionServiceHash() =>
    r'11086965854ef25ca48d28aa32378b2f1a87ed49';

/// See also [nativeCompressionService].
@ProviderFor(nativeCompressionService)
final nativeCompressionServiceProvider =
    Provider<NativeCompressionService>.internal(
      nativeCompressionService,
      name: r'nativeCompressionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nativeCompressionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NativeCompressionServiceRef = ProviderRef<NativeCompressionService>;
String _$documentRepositoryHash() =>
    r'744bbf6682ad78254257db903ca2631d2d39bd69';

/// See also [documentRepository].
@ProviderFor(documentRepository)
final documentRepositoryProvider = FutureProvider<DocumentRepository>.internal(
  documentRepository,
  name: r'documentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DocumentRepositoryRef = FutureProviderRef<DocumentRepository>;
String _$encryptionServiceControllerHash() =>
    r'f3b83982ef9eb164679ce0f4951a778914ae9052';

/// See also [EncryptionServiceController].
@ProviderFor(EncryptionServiceController)
final encryptionServiceControllerProvider =
    AsyncNotifierProvider<
      EncryptionServiceController,
      EncryptionService
    >.internal(
      EncryptionServiceController.new,
      name: r'encryptionServiceControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$encryptionServiceControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EncryptionServiceController = AsyncNotifier<EncryptionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
