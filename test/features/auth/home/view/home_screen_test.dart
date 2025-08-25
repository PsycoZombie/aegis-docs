import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:aegis_docs/features/home/widgets/document_card.dart';
import 'package:aegis_docs/features/home/widgets/folder_card.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// A "fake" implementation of the HomeViewModel for testing.
class FakeHomeViewModel extends HomeViewModel {
  @override
  HomeState build() {
    // Start at the root directory for this test.
    return const HomeState();
  }
}

// A "fake" implementation of the WalletViewModel for testing.
class FakeWalletViewModel extends WalletViewModel {
  FakeWalletViewModel(this._testState);
  final WalletState _testState;

  @override
  Future<WalletState> build(String? folderPath) async {
    return _testState;
  }
}

void main() {
  group('HomeScreen', () {
    testWidgets('displays folders and files from the wallet provider', (
      WidgetTester tester,
    ) async {
      // Arrange: Create mock data to be provided to the screen.
      final mockFolders = [
        const FolderModel(name: 'Folder 1', path: '/folder1'),
        const FolderModel(name: 'Folder 2', path: '/folder2'),
      ];
      final mockFiles = [
        const DocumentModel(name: 'File 1', path: '/file1.pdf'),
      ];
      final mockWalletState = WalletState(
        folders: mockFolders,
        files: mockFiles,
      );

      // Pump the HomeScreen widget within a ProviderScope, overriding the
      // providers to return our fake data.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith(FakeHomeViewModel.new),
            walletViewModelProvider(null).overrideWith(
              () => FakeWalletViewModel(mockWalletState),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Wait for the UI to settle after the initial loading state.
      await tester.pumpAndSettle();

      // Assert: Verify that the correct number of FolderCard and DocumentCard
      // widgets are found on the screen.
      expect(find.byType(FolderCard), findsNWidgets(2));
      expect(find.byType(DocumentCard), findsOneWidget);
      // Verify that the empty folder message is not shown.
      expect(find.text('This folder is empty.'), findsNothing);
    });

    testWidgets('displays "empty folder" message when there are no items', (
      WidgetTester tester,
    ) async {
      // Arrange: Create an empty wallet state.
      const mockWalletState = WalletState();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith(FakeHomeViewModel.new),
            // The override function should take no arguments.
            walletViewModelProvider(null).overrideWith(
              () => FakeWalletViewModel(mockWalletState),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verify that the "empty" message is
      // shown and no cards are rendered.
      expect(find.text('This folder is empty.'), findsOneWidget);
      expect(find.byType(FolderCard), findsNothing);
      expect(find.byType(DocumentCard), findsNothing);
    });
  });
}
