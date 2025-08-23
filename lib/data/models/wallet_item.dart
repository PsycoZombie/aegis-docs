import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A sealed class representing an item in the secure wallet.
///
/// Using a sealed class ensures that any item in the
/// wallet can only be one of the
/// predefined subtypes (`DocumentModel` or `FolderModel`),
/// providing type safety.
sealed class WalletItem extends Equatable {
  /// Creates a constant instance of a wallet item.
  const WalletItem({required this.name, required this.path});

  /// The display name of the file or folder.
  final String name;

  /// The full path of the file or folder within the app's internal storage.
  final String path;

  @override
  List<Object?> get props => [name, path];
}

/// A data model representing a folder within the wallet.
class FolderModel extends WalletItem {
  /// Creates a constant instance of a folder model.
  const FolderModel({required super.name, required super.path});

  @override
  List<Object?> get props => [name, path];
}

/// A data model representing an encrypted document within the wallet.
class DocumentModel extends WalletItem {
  /// Creates a constant instance of a document model.
  const DocumentModel({
    required super.name,
    required super.path,
    this.decryptedBytes,
  });

  /// The decrypted content of the document as raw bytes.
  ///
  /// This property is optional and should only be loaded when a user explicitly
  /// opens a document to view it. It should be `null` when simply listing
  /// axsls in a folder to ensure high performance.
  final Uint8List? decryptedBytes;

  @override
  List<Object?> get props => [name, path, decryptedBytes];
}
