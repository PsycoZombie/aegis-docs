/// A central repository for constant values used throughout the application.
///
/// Using a constants file helps prevent typos and makes it easy to update
/// key values in a single location.
class AppConstants {
  // --- Platform Channel --- //
  /// The name for the method channel used to communicate with native code.
  static const String platformChannelName = 'com.aegis_docs.platform';

  // --- File System --- //
  /// The name of the private subdirectory within the app's documents directory
  /// where the secure wallet is stored.
  static const String privateWalletDirectory = 'aegis_wallet';

  /// The name of the public subdirectory within the device's "Downloads" folder
  /// where files are exported.
  static const String publicExportDirectory = 'AegisDocs';

  // --- Cryptography --- //
  /// The identifier used as a key to store the main data encryption key in
  /// secure storage.
  static const String encryptionKeyIdentifier = 'aegis_docs_encryption_key';

  // --- Cloud Sync --- //
  /// The file name for the complete wallet backup stored in Google Drive.
  static const String backupFileName = 'aegis_wallet_backup.zip';

  /// The name of the JSON file inside the backup archive that contains the
  /// encrypted data key.
  static const String backupKeyFileName = 'aegis_key.json';
}
