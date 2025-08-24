// to avoid verbose
// ignore_for_file: public_member_api_docs

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

  // --- Route Paths --- //
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeDocumentDetail = '/document/:fileName';
  static const String routeSettings = '/settings';
  static const String routeHub = '/hub';
  static const String routeResize = '/hub/resize';
  static const String routeCompress = '/hub/compress';
  static const String routeEdit = '/hub/edit';
  static const String routeImageFormat = '/hub/image-format';
  static const String routeImagesToPdf = '/hub/images-to-pdf';
  static const String routePdfToImages = '/hub/pdf-to-images';
  static const String routePdfCompression = '/hub/pdf-compression';
  static const String routePdfSecurity = '/hub/pdf-security';

  // --- Method Channel Keys --- //
  static const String keyTheme = 'appTheme';
  static const String keyCleanupDuration = 'cleanup_duration';
  static const String keyAppDataFolder = 'appDataFolder';
  static const String keySalt = 'salt';
  static const String keyIv = 'iv';
  static const String keyEncryptionKey = 'key';
  static const String methodSaveToDownloads = 'saveToDownloads';
  static const String paramFileName = 'fileName';
  static const String paramData = 'data';
  static const String methodCleanupFiles = 'cleanupExportedFiles';
  static const String paramExpiration = 'expirationInMinutes';
  static const String methodCompressPdf = 'compressPdf';
  static const String paramFilePath = 'filePath';
  static const String paramOutputPath = 'outputPath';
  static const String paramSizeLimit = 'sizeLimit';
  static const String paramPreserveText = 'preserveText';

  // --- UI Text --- //
  static const String titleSecureWallet = 'Secure Wallet';
  static const String titleNewFolder = 'New Folder';
  static const String titleSettings = 'Settings';
  static const String titleLogout = 'Logout';
  static const String titleStartNewPrep = 'Start New Prep';
  static const String titleApproveSignIn = 'Approve Sign in';
  static const String titleAuthRequired = 'Authentication Required';
  static const String titleResizeImage = 'Resize Image';
  static const String titleCompressImage = 'Compress Image';
  static const String titleCropEditImage = 'Crop & Edit Image';
  static const String titleChangeImageFormat = 'Change Image Format';
  static const String titleImagesToPdf = 'Images to PDF';
  static const String titlePdfToImages = 'PDF to Images';
  static const String titleCompressPdf = 'Compress PDF (Native)';
  static const String titlePdfSecurity = 'PDF Security';
}
