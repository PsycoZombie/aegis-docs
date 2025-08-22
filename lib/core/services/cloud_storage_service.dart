import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class CloudStorageService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const List<String> _driveScope = [drive.DriveApi.driveAppdataScope];

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '168730393077-s73bqsr2vj5tde5s0v7an0df78628c9d'
            '.apps.googleusercontent.com',
      );

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
      return false;
    }
  }

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

      final updateFile = drive.File()..name = fileName;
      await driveApi.files.update(updateFile, fileId, uploadMedia: media);
    } else {
      debugPrint('Creating new backup file...');

      final createFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];
      await driveApi.files.create(createFile, uploadMedia: media);
    }
    debugPrint('Backup upload complete.');
  }

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
      builder.add,
      onDone: () {
        debugPrint('Backup download complete.');
        completer.complete(builder.toBytes());
      },
      onError: (Object error, StackTrace? stackTrace) {
        completer.completeError(error, stackTrace);
      },
    );
    return completer.future;
  }
}
