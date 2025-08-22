// file: core/services/cloud_storage_service.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class CloudStorageService {
  // THE FIX: Use the singleton instance, as you correctly pointed out.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // Define the required scope for the private App Data Folder.
  static const _driveScope = [drive.DriveApi.driveAppdataScope];
  /*
  // / Signs in the user, ensures Drive permissions are granted, and returns an
  // / authenticated DriveApi client. Returns null if the user cancels.
  // Future<drive.DriveApi?> _getDriveApi() async {
  //   try {
  //     // 1. Initialize to prepare for sign-in.
  //     await _googleSignIn.initialize();

  //     // 2. THE FIX: Use the modern authenticate() method.
  //     final googleUser = await _googleSignIn.authenticate();

  //     // 3. Check if the required Drive scope has already been granted.
  //     final auth = await googleUser.authorizationClient.authorizationForScopes(
  //       _driveScope,
  //     );

  //     // 4. If the scope is not granted, explicitly request it.
  //     if (auth == null) {
  //       debugPrint('Drive scope not granted. Requesting...');
  //       final granted = await googleUser.authorizationClient.authorizeScopes(
  //         _driveScope,
  //       );
  //     }

  //     // 5. THE FIX: Use the authorizationClient directly.
  //     // It is an authenticated http.Client that can be used with the Google APIs.
  //     final authClient = googleUser.authorizationClient;

  //     // 6. Create and return the DriveApi instance.
  //     return drive.DriveApi(authClient as Client);
  //   } catch (e) {
  //     debugPrint('Error getting Drive API client: $e');
  //     // Attempt to sign out to clear any corrupted state.
  //     await _googleSignIn.signOut();
  //     return null;
  //   }
  // }
  */

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '***REMOVED***',
      );

      final googleUser = await _googleSignIn.authenticate(
        scopeHint: _driveScope,
      );

      // Request Drive scope if not already granted
      final authz = await googleUser.authorizationClient.authorizationForScopes(
        _driveScope,
      );
      if (authz == null) {
        await googleUser.authorizationClient.authorizeScopes(_driveScope);
      }

      // Pull headers from the authorization client
      final headers = await googleUser.authorizationClient.authorizationHeaders(
        _driveScope,
      );
      final accessToken = headers!['Authorization']!.split(' ').last;

      // Build AccessCredentials for googleapis_auth
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null, // no refresh token from sign_in flow
        _driveScope,
      );

      final httpClient = auth.authenticatedClient(http.Client(), credentials);

      return drive.DriveApi(httpClient);
    } catch (e) {
      debugPrint('Error getting Drive API client: $e');
      await _googleSignIn.signOut();
      return null;
    }
  }

  Future<bool> deleteBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    final existingFiles = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
    );

    if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
      final fileId = existingFiles.files!.first.id!;
      debugPrint('Deleting backup file...');
      await driveApi.files.delete(fileId);
      debugPrint('Backup delete complete.');
      return true;
    } else {
      debugPrint('No backup file found to delete.');
      return false; // No file was found to delete
    }
  }

  /// Uploads the backup file to the user's private App Data Folder on Google Drive.
  Future<void> uploadBackup(Uint8List data, String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    final media = drive.Media(Stream.value(data), data.length);

    final existingFiles = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
    );

    if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
      final fileId = existingFiles.files!.first.id!;
      debugPrint('Updating existing backup file...');
      // THE FIX: When updating, create a File object without the 'parents' field.
      final updateFile = drive.File()..name = fileName;
      await driveApi.files.update(updateFile, fileId, uploadMedia: media);
    } else {
      debugPrint('Creating new backup file...');
      // When creating, the File object MUST have the 'parents' field.
      final createFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];
      await driveApi.files.create(createFile, uploadMedia: media);
    }
    debugPrint('Backup upload complete.');
  }

  /// Downloads the backup file from the user's App Data Folder.
  /// Returns null if no backup is found.
  Future<Uint8List?> downloadBackup(String fileName) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    final existingFiles = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
    );

    if (existingFiles.files == null || existingFiles.files!.isEmpty) {
      debugPrint('No backup file found on Google Drive.');
      return null;
    }

    final fileId = existingFiles.files!.first.id!;
    debugPrint('Downloading backup file...');
    final response =
        await driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final completer = Completer<Uint8List>();
    final builder = BytesBuilder();
    response.stream.listen(
      (data) => builder.add(data),
      onDone: () {
        debugPrint('Backup download complete.');
        completer.complete(builder.toBytes());
      },
      onError: (error) => completer.completeError(error),
    );
    return completer.future;
  }
}
