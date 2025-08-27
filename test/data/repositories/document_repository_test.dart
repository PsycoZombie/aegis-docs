import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/core/media_processing/pdf_processor.dart';
import 'package:aegis_docs/core/services/cloud_storage_service.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'document_repository_test.mocks.dart';

// This annotation tells build_runner to
// generate mock classes for all our services.
@GenerateMocks([
  FilePickerService,
  ImageProcessor,
  PdfProcessor,
  CloudStorageService,
  EncryptionService,
  FileStorageService,
  NativePdfCompressionService,
])
// A fake implementation of the PathProviderPlatform. This allows us to control
// what paths are returned during a test,
// without touching the actual file system.
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/fake/temp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declare mock objects for all dependencies.
  late MockFilePickerService mockFilePickerService;
  late MockImageProcessor mockImageProcessor;
  late MockPdfProcessor mockPdfProcessor;
  late MockCloudStorageService mockCloudStorageService;
  late MockEncryptionService mockEncryptionService;
  late MockFileStorageService mockFileStorageService;
  late MockNativePdfCompressionService mockNativePdfCompressionService;
  // Declare the instance of the class we are testing.
  late DocumentRepository documentRepository;
  late MemoryFileSystem memoryFileSystem;

  // This runs before each test, ensuring a clean state.
  setUp(() {
    // Initialize all the mock objects.
    PathProviderPlatform.instance = FakePathProviderPlatform();
    memoryFileSystem = MemoryFileSystem();
    mockFilePickerService = MockFilePickerService();
    mockImageProcessor = MockImageProcessor();
    mockPdfProcessor = MockPdfProcessor();
    mockCloudStorageService = MockCloudStorageService();
    mockEncryptionService = MockEncryptionService();
    mockFileStorageService = MockFileStorageService();
    mockNativePdfCompressionService = MockNativePdfCompressionService();

    // Create an instance of the DocumentRepository, injecting all the mocks.
    documentRepository = DocumentRepository(
      filePickerService: mockFilePickerService,
      imageProcessor: mockImageProcessor,
      pdfProcessor: mockPdfProcessor,
      nativePdfCompressionService: mockNativePdfCompressionService,
      fileStorageService: mockFileStorageService,
      encryptionService: mockEncryptionService,
      cloudStorageService: mockCloudStorageService,
    );
  });

  group('DocumentRepository', () {
    // --- Wallet & File System Tests --- //
    test('listAllFolders should call the file storage service', () async {
      when(
        mockFileStorageService.listAllFoldersRecursively(),
      ).thenAnswer((_) async => []);
      await documentRepository.listAllFolders();
      verify(mockFileStorageService.listAllFoldersRecursively()).called(1);
    });

    test('listWalletContents should call the file storage service', () async {
      when(
        mockFileStorageService.listDirectoryContents(
          folderPath: anyNamed('folderPath'),
        ),
      ).thenAnswer((_) async => []);
      await documentRepository.listWalletContents(folderPath: 'test');
      verify(
        mockFileStorageService.listDirectoryContents(folderPath: 'test'),
      ).called(1);
    });

    test('createFolderInWallet should call the file storage service', () async {
      when(
        mockFileStorageService.createFolder(
          folderName: anyNamed('folderName'),
          parentFolderPath: anyNamed('parentFolderPath'),
        ),
      ).thenAnswer((_) async {});
      await documentRepository.createFolderInWallet(folderName: 'new_folder');
      verify(
        mockFileStorageService.createFolder(folderName: 'new_folder'),
      ).called(1);
    });

    test(
      'deleteFolderFromWallet should call the file storage service',
      () async {
        when(
          mockFileStorageService.deleteFolder(
            folderPath: anyNamed('folderPath'),
          ),
        ).thenAnswer((_) async {});
        await documentRepository.deleteFolderFromWallet(
          folderPath: 'folder_to_delete',
        );
        verify(
          mockFileStorageService.deleteFolder(folderPath: 'folder_to_delete'),
        ).called(1);
      },
    );

    // --- Document Encryption & Management Tests --- //
    test(
      'saveEncryptedDocument should call '
      'encrypt and then saveToPrivateDirectory',
      () async {
        final testData = Uint8List.fromList([1, 2, 3]);
        final encryptedData = Uint8List.fromList([4, 5, 6]);
        const fileName = 'test.txt';

        when(
          mockEncryptionService.encrypt(any),
        ).thenAnswer((_) async => encryptedData);
        when(
          mockFileStorageService.saveToPrivateDirectory(
            fileName: anyNamed('fileName'),
            data: anyNamed('data'),
            folderPath: anyNamed('folderPath'),
          ),
        ).thenAnswer((_) async => '/fake/path/test.txt');

        await documentRepository.saveEncryptedDocument(
          fileName: fileName,
          data: testData,
        );

        verify(mockEncryptionService.encrypt(testData)).called(1);
        verify(
          mockFileStorageService.saveToPrivateDirectory(
            fileName: fileName,
            data: encryptedData,
          ),
        ).called(1);
      },
    );

    test('loadDecryptedDocument should call load and then decrypt', () async {
      final encryptedData = Uint8List.fromList([4, 5, 6]);
      final decryptedData = Uint8List.fromList([1, 2, 3]);
      const fileName = 'test.txt';

      when(
        mockFileStorageService.loadFromPrivateDirectory(
          fileName: anyNamed('fileName'),
          folderPath: anyNamed('folderPath'),
        ),
      ).thenAnswer((_) async => encryptedData);
      when(
        mockEncryptionService.decrypt(any),
      ).thenAnswer((_) async => decryptedData);

      final result = await documentRepository.loadDecryptedDocument(
        fileName: fileName,
      );

      expect(result, equals(decryptedData));
      verify(
        mockFileStorageService.loadFromPrivateDirectory(fileName: fileName),
      ).called(1);
      verify(mockEncryptionService.decrypt(encryptedData)).called(1);
    });

    // --- Public File Operations Tests --- //
    test('pickImage should call the file picker service', () async {
      when(
        mockFilePickerService.pickImage(),
      ).thenAnswer((_) async => (null, false));
      await documentRepository.pickImage();
      verify(mockFilePickerService.pickImage()).called(1);
    });

    // --- Image Processing Tests --- //
    test('cropImage should call the image processor', () async {
      final testData = Uint8List(0);
      final theme = ThemeData();
      when(
        mockImageProcessor.crop(
          imageBytes: anyNamed('imageBytes'),
          theme: anyNamed('theme'),
        ),
      ).thenAnswer((_) async => null);
      await documentRepository.cropImage(testData, theme: theme);
      verify(
        mockImageProcessor.crop(imageBytes: testData, theme: theme),
      ).called(1);
    });

    // --- PDF Processing Tests --- //
    test('lockPdf should call the pdf processor', () async {
      final testData = Uint8List(0);
      const password = 'pass';
      when(
        mockPdfProcessor.lockPdf(
          pdfBytes: anyNamed('pdfBytes'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => testData);
      await documentRepository.lockPdf(testData, password: password);
      verify(
        mockPdfProcessor.lockPdf(pdfBytes: testData, password: password),
      ).called(1);
    });

    // --- Native Compression Tests --- //
    test(
      'compressPdfWithNative should call the native compression service',
      () async {
        when(
          mockNativePdfCompressionService.compressPdf(
            filePath: anyNamed('filePath'),
            sizeLimit: anyNamed('sizeLimit'),
            preserveText: anyNamed('preserveText'),
          ),
        ).thenAnswer((_) async => '/fake/compressed.pdf');

        await documentRepository.compressPdfWithNative(
          filePath: '/fake/original.pdf',
          sizeLimit: 500,
          preserveText: true,
        );

        verify(
          mockNativePdfCompressionService.compressPdf(
            filePath: '/fake/original.pdf',
            sizeLimit: 500,
            preserveText: true,
          ),
        ).called(1);
      },
    );

    // --- Cloud Backup & Restore Tests --- //
    test(
      'deleteBackupFromDrive should call the cloud storage service',
      () async {
        when(
          mockCloudStorageService.deleteBackup(any),
        ).thenAnswer((_) async => true);
        await documentRepository.deleteBackupFromDrive();
        verify(mockCloudStorageService.deleteBackup(any)).called(1);
      },
    );

    test(
      'backupWalletToDrive should call all necessary services in order',
      () async {
        // Arrange
        const password = 'password';
        final fakeKeyData = {'key': 'data'};
        // Create the fake directory within the in-memory file system.
        final fakeWalletDir = memoryFileSystem.directory('/fake/wallet')
          ..createSync(recursive: true);

        when(
          mockEncryptionService.getEncryptedDataKeyForBackup(any),
        ).thenAnswer((_) async => fakeKeyData);
        when(
          mockFileStorageService.getBaseWalletDirectory(),
        ).thenAnswer((_) async => fakeWalletDir);
        when(
          mockCloudStorageService.uploadBackup(any, any),
        ).thenAnswer((_) async {});

        // Act
        await documentRepository.backupWalletToDrive(password);

        // Assert
        verify(
          mockEncryptionService.getEncryptedDataKeyForBackup(password),
        ).called(1);
        verify(mockFileStorageService.getBaseWalletDirectory()).called(1);
        verify(mockCloudStorageService.uploadBackup(any, any)).called(1);
      },
    );
  });
}
