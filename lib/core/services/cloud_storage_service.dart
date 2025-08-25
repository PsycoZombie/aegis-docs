import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/app/config/app_secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

/// Provides an instance of [CloudStorageService] for dependency injection.
final cloudStorageServiceProvider = Provider<CloudStorageService>((ref) {
  return CloudStorageService();
});

/// A service for handling backup and restore ops
/// with Google Drive's AppData folder.
class CloudStorageService {
  /// Creates an instance of the cloud storage service.
  /// Optional [driveApi] and [googleSignIn] can be
  /// provided for testing purposes.
  CloudStorageService({
    drive.DriveApi? driveApi,
    GoogleSignIn? googleSignIn,
  }) : _driveApi = driveApi,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final drive.DriveApi? _driveApi;
  final GoogleSignIn _googleSignIn;

  /// The OAuth 2.0 Web Client ID from the Google Cloud project.
  final String serverClientId = AppSecrets.googleServerClientId;
  static const List<String> _driveScope = [drive.DriveApi.driveAppdataScope];

  /// Gets a DriveApi instance. In tests, returns the injected mock.
  /// In production, it initiates the full Google Sign-In flow.
  Future<drive.DriveApi?> _getDriveApi() async {
    if (_driveApi != null) return _driveApi; // Return the mock if it exists
    return _getDriveApiFromSignIn(); // Proceed with real sign-in otherwise
  }

  /// Authenticates the user with Google and returns
  /// an authorized Drive API client.
  Future<drive.DriveApi?> _getDriveApiFromSignIn() async {
    try {
      if (serverClientId.isEmpty) {
        debugPrint('Error: Google Server Client ID is not configured.');
        return null;
      }

      await _googleSignIn.initialize(serverClientId: serverClientId);
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: _driveScope,
      );

      final authz = await googleUser.authorizationClient.authorizationForScopes(
        _driveScope,
      );
      if (authz == null) {
        await googleUser.authorizationClient.authorizeScopes(_driveScope);
      }

      final headers = await googleUser.authorizationClient.authorizationHeaders(
        _driveScope,
      );
      final accessToken = headers!['Authorization']!.split(' ').last;

      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null,
        _driveScope,
      );

      final httpClient = auth.authenticatedClient(http.Client(), credentials);
      return drive.DriveApi(httpClient);
    } on Exception catch (e) {
      debugPrint('Error getting Drive API client: $e');
      await _googleSignIn.signOut();
      return null;
    }
  }

  /// Deletes a backup file from the Google Drive AppData folder.
  Future<bool?> deleteBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;
    try {
      final existingFiles = await driveApi.files.list(
        spaces: AppConstants.keyAppDataFolder,
        q: "name = '$fileName'",
      );
      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        final fileId = existingFiles.files!.first.id!;
        await driveApi.files.delete(fileId);
        return true;
      } else {
        return null;
      }
    } on Exception catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }

  /// Uploads a backup file to the Google Drive AppData folder.
  ///
  /// If a file with the same [fileName] already exists, it is overwritten.
  Future<void> uploadBackup(Uint8List data, String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    try {
      final media = drive.Media(Stream.value(data), data.length);
      final existingFiles = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$fileName'",
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        final fileId = existingFiles.files!.first.id;
        debugPrint('Updating existing backup file...');
        await driveApi.files.update(drive.File(), fileId!, uploadMedia: media);
      } else {
        debugPrint('Creating new backup file...');
        final createFile = drive.File()
          ..name = fileName
          ..parents = ['appDataFolder'];
        await driveApi.files.create(createFile, uploadMedia: media);
      }
      debugPrint('Backup upload complete.');
    } on Exception catch (e) {
      debugPrint('Error uploading backup: $e');
    }
  }

  /// Downloads a backup file from the Google Drive AppData folder.
  ///
  /// Returns file data as [Uint8List], or `null` if the
  /// file doesn't exist or an error occurs.
  Future<Uint8List?> downloadBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    try {
      final existingFiles = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$fileName'",
      );

      if (existingFiles.files == null || existingFiles.files!.isEmpty) {
        debugPrint('No backup file found on Google Drive.');
        return null;
      }

      final fileId = existingFiles.files!.first.id;
      debugPrint('Downloading backup file...');
      final response =
          await driveApi.files.get(
                fileId!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final completer = Completer<Uint8List>();
      final builder = BytesBuilder();

      response.stream.listen(
        builder.add,
        onDone: () {
          debugPrint('Backup download complete.');
          completer.complete(builder.toBytes());
        },
        onError: (Object error, StackTrace? stackTrace) {
          completer.completeError(error, stackTrace);
        },
        cancelOnError: true,
      );
      return completer.future;
    } on Exception catch (e) {
      debugPrint('Error downloading backup: $e');
      return null;
    }
  }
}
