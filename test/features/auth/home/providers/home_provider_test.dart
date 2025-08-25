import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:path/path.dart' as p;

import 'home_provider_test.mocks.dart';

// This annotation tells build_runner to generate a mock for DocumentRepository.
@GenerateMocks([DocumentRepository])
// A "fake" implementation of the WalletViewModel for testing.
// This is more robust for testing Riverpod
// notifiers than using mockito directly.
class FakeWalletViewModel extends WalletViewModel {
  bool createFolderCalled = false;
  bool deleteFolderCalled = false;
  bool renameFolderCalled = false;

  @override
  Future<WalletState> build(String? folderPath) async {
    // Return a default empty state.
    return const WalletState();
  }

  @override
  Future<bool> createFolder({
    required String folderName,
    String? parentFolderPath,
  }) async {
    createFolderCalled = true;
    return true; // Assume success for the test
  }

  @override
  Future<void> deleteFolder({required String folderPathToDelete}) async {
    deleteFolderCalled = true;
  }

  @override
  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    renameFolderCalled = true;
  }
}

void main() {
  group('HomeViewModel', () {
    test('initial state should have null currentFolderPath', () {
      // Arrange: Create a container without any overrides for this simple test.
      final container = ProviderContainer();
      addTearDown(
        container.dispose,
      ); // Ensure the container is disposed after the test.

      // Act
      final state = container.read(homeViewModelProvider);

      // Assert
      expect(state.currentFolderPath, isNull);
    });

    test(
      'navigateToFolder and navigateUp should correctly update the path',
      () {
        // Arrange
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(homeViewModelProvider.notifier)
          // Act & Assert: Navigate down
          ..navigateToFolder('folderA');
        expect(
          container.read(homeViewModelProvider).currentFolderPath,
          'folderA',
        );

        // Act & Assert: Navigate deeper
        notifier.navigateToFolder('folderB');
        expect(
          container.read(homeViewModelProvider).currentFolderPath,
          p.join('folderA', 'folderB'),
        );

        // Act & Assert: Navigate up
        notifier.navigateUp();
        expect(
          container.read(homeViewModelProvider).currentFolderPath,
          'folderA',
        );

        // Act & Assert: Navigate back to root
        notifier.navigateUp();
        expect(container.read(homeViewModelProvider).currentFolderPath, isNull);
      },
    );

    test(
      'createFolder should call the wallet provider and invalidate',
      () async {
        // Arrange
        final fakeWalletNotifier = FakeWalletViewModel();
        final container = ProviderContainer(
          overrides: [
            walletViewModelProvider(
              null,
            ).overrideWith(() => fakeWalletNotifier),
            documentRepositoryProvider.overrideWith(
              (ref) async => MockDocumentRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final homeNotifier = container.read(homeViewModelProvider.notifier);

        var invalidated = false;
        container.listen(walletViewModelProvider(null), (prev, next) {
          invalidated = true;
        });

        // Act
        await homeNotifier.createFolder('new_folder');

        // Assert
        expect(fakeWalletNotifier.createFolderCalled, isTrue);
        expect(invalidated, isTrue);
      },
    );

    test(
      'deleteItem should call deleteFolder on WalletViewModel and invalidate',
      () async {
        // Arrange
        final fakeWalletNotifier = FakeWalletViewModel();
        final container = ProviderContainer(
          overrides: [
            walletViewModelProvider(
              null,
            ).overrideWith(() => fakeWalletNotifier),
            documentRepositoryProvider.overrideWith(
              (ref) async => MockDocumentRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final homeNotifier = container.read(homeViewModelProvider.notifier);

        var invalidated = false;
        container.listen(walletViewModelProvider(null), (prev, next) {
          invalidated = true;
        });

        // Act
        await homeNotifier.deleteItem('folderA', isFolder: true);

        // Assert
        expect(fakeWalletNotifier.deleteFolderCalled, isTrue);
        expect(invalidated, isTrue);
      },
    );
  });
}
