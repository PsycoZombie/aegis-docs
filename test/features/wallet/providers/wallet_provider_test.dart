import 'dart:io';

import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../auth/home/providers/home_provider_test.mocks.dart';

// This annotation tells build_runner to generate a mock for DocumentRepository.
@GenerateMocks([DocumentRepository])
void main() {
  late MockDocumentRepository mockDocumentRepository;

  // This helper function creates a ProviderContainer and overrides the
  // documentRepositoryProvider to return our mock.
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWith(
          (ref) async => mockDocumentRepository,
        ),
      ],
    );
    // Ensure the container is disposed after each test.
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    // Initialize a fresh mock before each test.
    mockDocumentRepository = MockDocumentRepository();
  });

  group('WalletViewModel', () {
    test(
      'build method should fetch, convert, and sort '
      'file system entities correctly',
      () async {
        // Arrange: Define the raw data the repository will return.
        final mockEntities = [
          File('/fake/path/document_b.txt'),
          Directory('/fake/path/folder_z'),
          File('/fake/path/document_a.pdf'),
          Directory('/fake/path/folder_x'),
        ];
        // When listWalletContents is called, return our mock data.
        when(
          mockDocumentRepository.listWalletContents(
            folderPath: anyNamed('folderPath'),
          ),
        ).thenAnswer((_) async => mockEntities);

        final container = createContainer();

        // Act: Read the provider to trigger the build method.
        final result = await container.read(
          walletViewModelProvider(null).future,
        );

        // Assert: Verify that the result is correctly converted and sorted.
        // Check folders
        expect(result.folders.length, 2);
        expect(
          result.folders[0].name,
          'folder_x',
        ); // Should be sorted alphabetically
        expect(result.folders[1].name, 'folder_z');
        expect(result.folders[0], isA<FolderModel>());

        // Check files
        expect(result.files.length, 2);
        expect(result.files[0].name, 'document_a.pdf'); // Should be sorted
        expect(result.files[1].name, 'document_b.txt');
        expect(result.files[0], isA<DocumentModel>());
      },
    );

    test('createFolder should return false if folder already exists', () async {
      // Arrange
      final container = createContainer();
      // Manually set the initial state of the provider for this test.
      container
          .read(walletViewModelProvider(null).notifier)
          .state = const AsyncData(
        WalletState(
          folders: [FolderModel(name: 'existing_folder', path: '')],
        ),
      );
      final notifier = container.read(walletViewModelProvider(null).notifier);

      // Act: Try to create a folder with the same name (case-insensitive).
      final result = await notifier.createFolder(folderName: 'Existing_Folder');

      // Assert: The method should return false and NOT call the repository.
      expect(result, isFalse);
      verifyNever(
        mockDocumentRepository.createFolderInWallet(
          folderName: anyNamed('folderName'),
          parentFolderPath: anyNamed('parentFolderPath'),
        ),
      );
    });

    test(
      'deleteFolder should call the repository with the correct path',
      () async {
        // Arrange
        when(
          mockDocumentRepository.deleteFolderFromWallet(
            folderPath: anyNamed('folderPath'),
          ),
        ).thenAnswer((_) async {});
        final container = createContainer();
        final notifier = container.read(walletViewModelProvider(null).notifier);

        // Act
        await notifier.deleteFolder(folderPathToDelete: '/fake/path/to/delete');

        // Assert: Verify the repository method was called with the exact path.
        verify(
          mockDocumentRepository.deleteFolderFromWallet(
            folderPath: '/fake/path/to/delete',
          ),
        ).called(1);
      },
    );
  });
}
