import 'dart:async';
import 'dart:io';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/app/config/app_secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A wrapper class that implements http.Client
/// and adds the Google authentication
/// headers to every outgoing request.
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

/// Provides an instance of [CloudStorageService] for dependency injection.
final cloudStorageServiceProvider = Provider<CloudStorageService>((ref) {
  return CloudStorageService();
});

/// A service for handling backup and restore
/// ops with Google Drive's AppData folder.
class CloudStorageService {
  /// Creates an instance of the cloud storage service.
  /// An optional [driveApi] can be provided for testing purposes.
  CloudStorageService({
    drive.DriveApi? driveApi,
    // Add googleSignIn for testability, but default to the real instance.
    GoogleSignIn? googleSignIn,
  }) : _driveApi = driveApi,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final drive.DriveApi? _driveApi;
  // For testing.
  // ignore: unused_field
  final GoogleSignIn _googleSignIn;

  /// The OAuth 2.0 Web Client ID from the Google Cloud project.
  final String serverClientId = AppSecrets.googleServerClientId;
  static const List<String> _driveScope = [drive.DriveApi.driveAppdataScope];

  /// Gets a DriveApi instance. In tests, returns the injected mock.
  /// In production, it initiates the full Google Sign-In flow.
  Future<drive.DriveApi?> _getDriveApi() async {
    if (_driveApi != null) return _driveApi;
    return _getDriveApiFromSignIn();
  }

  /// Authenticates the user with Google and
  /// returns an authorized Drive API client.
  Future<drive.DriveApi?> _getDriveApiFromSignIn() async {
    try {
      if (serverClientId.isEmpty) {
        debugPrint('Error: Google Server Client ID is not configured.');
        return null;
      }

      // Ensure GoogleSignIn is initialized
      await GoogleSignIn.instance.initialize(
        clientId: serverClientId,
        serverClientId: AppSecrets.googleServerClientId,
      );

      // Start authentication
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Request authorization headers for Drive access
      final authHeaders = await googleUser.authorizationClient
          .authorizationHeaders(_driveScope);
      if (authHeaders == null) {
        debugPrint('Failed to get authorization headers.');
        return null;
      }

      final authClient = _GoogleAuthClient(authHeaders);
      return drive.DriveApi(authClient);
    } on Object catch (e) {
      debugPrint('Error getting Drive API client: $e');
      await GoogleSignIn.instance.signOut();
      return null;
    }
  }

  /// Deletes a backup file from the Google Drive AppData folder.
  ///
  /// Returns:
  /// - `true` if the file was found and deleted successfully.
  /// - `null` if no backup file was found.
  /// - `false` if an error occurred during deletion.
  Future<bool?> deleteBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;
    try {
      final existingFiles = await driveApi.files.list(
        spaces: AppConstants.keyAppDataFolder,
        q: "name = '$fileName'",
      );
      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        final fileId = existingFiles.files!.first.id;
        if (fileId != null) {
          await driveApi.files.delete(fileId);
          return true;
        }
      }
      return null;
    } on Object catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }

  /// Uploads a backup file to the Google Drive AppData
  /// folder by streaming from a [File].
  ///
  /// If a file with the same [fileName] already exists, it is overwritten.
  Future<void> uploadBackup(File backupFile, String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    try {
      // Stream the backup from the file on disk instead of memory.
      final media = drive.Media(
        backupFile.openRead(),
        await backupFile.length(),
        contentType: 'application/zip',
      );

      final existingFiles = await driveApi.files.list(
        spaces: AppConstants.keyAppDataFolder,
        q: "name = '$fileName'",
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        final fileId = existingFiles.files!.first.id;
        if (fileId != null) {
          debugPrint('Updating existing backup file...');
          await driveApi.files.update(
            drive.File(),
            fileId,
            uploadMedia: media,
            uploadOptions: drive.UploadOptions.resumable,
          );
        }
      } else {
        debugPrint('Creating new backup file...');
        final createFile = drive.File()
          ..name = fileName
          ..parents = [AppConstants.keyAppDataFolder];
        await driveApi.files.create(
          createFile,
          uploadMedia: media,
          uploadOptions: drive.UploadOptions.resumable,
        );
      }
      debugPrint('Backup upload complete.');
    } on Object catch (e) {
      debugPrint('Error uploading backup: $e');
    }
  }

  /// Downloads a backup file from Google Drive
  /// and saves it to a temporary [File].
  ///
  /// Returns the temporary [File], or `null` if
  /// the file doesn't exist or an error occurs.
  Future<File?> downloadBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    try {
      final existingFiles = await driveApi.files.list(
        spaces: AppConstants.keyAppDataFolder,
        q: "name = '$fileName'",
      );

      if (existingFiles.files == null || existingFiles.files!.isEmpty) {
        debugPrint('No backup file found on Google Drive.');
        return null;
      }

      final fileId = existingFiles.files!.first.id;
      if (fileId == null) return null;

      final mediaResponse =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      // Stream the download directly to a temporary file.
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      final sink = tempFile.openWrite();

      await mediaResponse.stream.pipe(sink);
      await sink.close();

      debugPrint('Backup download complete.');
      return tempFile;
    } on Object catch (e) {
      debugPrint('Error downloading backup: $e');
      return null;
    }
  }
}
