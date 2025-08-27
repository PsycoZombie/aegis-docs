import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file.
import 'settings_provider_test.mocks.dart';

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

  group('SettingsViewModel', () {
    test(
      'backupWallet should call repository and return true on success',
      () async {
        // Arrange
        when(
          mockDocumentRepository.backupWalletToDrive(any),
        ).thenAnswer((_) async {});
        final container = createContainer();
        final notifier = container.read(settingsViewModelProvider.notifier);

        // Act
        final result = await notifier.backupWallet('password');

        // Assert
        expect(result, isTrue);
        verify(
          mockDocumentRepository.backupWalletToDrive('password'),
        ).called(1);
      },
    );

    test('downloadBackup should return a File on success', () async {
      // Arrange
      // Create a temporary file to be returned by the mock.
      final tempDir = await Directory.systemTemp.createTemp();
      final mockFile = File('${tempDir.path}/test.zip');
      await mockFile.writeAsBytes(Uint8List.fromList([1, 2, 3]));

      when(
        mockDocumentRepository.downloadBackupFromDrive(),
      ).thenAnswer((_) async => mockFile);
      final container = createContainer();
      final notifier = container.read(settingsViewModelProvider.notifier);

      // Act
      final result = await notifier.downloadBackup();

      // Assert
      // Verify that the result is a File object
      // and that its content is correct.
      expect(result, isA<File>());
      expect(
        await result?.readAsBytes(),
        equals(Uint8List.fromList([1, 2, 3])),
      );
      verify(mockDocumentRepository.downloadBackupFromDrive()).called(1);

      // Clean up the temporary file.
      await tempDir.delete(recursive: true);
    });

    test(
      'deleteBackup should return success when repository returns true',
      () async {
        // Arrange
        when(
          mockDocumentRepository.deleteBackupFromDrive(),
        ).thenAnswer((_) async => true);
        final container = createContainer();
        final notifier = container.read(settingsViewModelProvider.notifier);

        // Act
        final result = await notifier.deleteBackup();

        // Assert
        expect(result, DeleteBackupResult.success);
        verify(mockDocumentRepository.deleteBackupFromDrive()).called(1);
      },
    );

    test(
      'deleteBackup should return notFound when repository returns null',
      () async {
        // Arrange
        when(
          mockDocumentRepository.deleteBackupFromDrive(),
        ).thenAnswer((_) async => null);
        final container = createContainer();
        final notifier = container.read(settingsViewModelProvider.notifier);

        // Act
        final result = await notifier.deleteBackup();

        // Assert
        expect(result, DeleteBackupResult.notFound);
      },
    );

    test(
      'deleteBackup should return error when repository throws exception',
      () async {
        // Arrange
        when(
          mockDocumentRepository.deleteBackupFromDrive(),
        ).thenThrow(Exception('Network error'));
        final container = createContainer();
        final notifier = container.read(settingsViewModelProvider.notifier);

        // Act
        final result = await notifier.deleteBackup();

        // Assert
        expect(result, DeleteBackupResult.error);
        // Check that the provider's state is now an error state.
        expect(container.read(settingsViewModelProvider).hasError, isTrue);
      },
    );
  });
}
