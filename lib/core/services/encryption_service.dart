import 'dart:convert';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

/// Provides an instance of [EncryptionService] for dependency injection.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Payload for the [_encryptIsolate].
class _EncryptIsolatePayload {
  _EncryptIsolatePayload(this.keyBytes, this.data);
  final Uint8List keyBytes;
  final Uint8List data;
}

/// Payload for the [_decryptIsolate].
class _DecryptIsolatePayload {
  _DecryptIsolatePayload(this.keyBytes, this.data);
  final Uint8List keyBytes;
  final Uint8List data;
}

/// Payload for the key wrapping isolate.
class _KeyWrapPayload {
  _KeyWrapPayload(this.masterPassword, this.dataKeyBytes);
  final String masterPassword;
  final Uint8List dataKeyBytes;
}

/// Payload for the key unwrapping isolate.
class _KeyUnwrapPayload {
  _KeyUnwrapPayload(this.masterPassword, this.backupData);
  final String masterPassword;
  final Map<String, dynamic> backupData;
}

/// Isolate entry point for data encryption using AES-256-CTR.
/// The 16-byte IV is prepended to the ciphertext.
Uint8List _encryptIsolate(_EncryptIsolatePayload params) {
  final key = enc.Key(params.keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  final iv = enc.IV.fromSecureRandom(16);
  final encrypted = encrypter.encryptBytes(params.data, iv: iv);
  // Prepend the IV to the encrypted data for use during decryption.
  return Uint8List.fromList(iv.bytes + encrypted.bytes);
}

/// Isolate entry point for data decryption using AES-256-CTR.
/// It expects the 16-byte IV to be prepended to the ciphertext.
Uint8List _decryptIsolate(_DecryptIsolatePayload params) {
  final key = enc.Key(params.keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  if (params.data.length < 16) {
    throw ArgumentError('Invalid encrypted data: too short to contain an IV.');
  }
  // Extract the IV from the first 16 bytes.
  final iv = enc.IV(params.data.sublist(0, 16));
  // The actual encrypted data starts after the IV.
  final encrypted = enc.Encrypted(params.data.sublist(16));
  return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
}

/// Isolate entry point to "wrap" (encrypt) the
/// main data key using a master password.
/// It uses PBKDF2 to derive a strong key from the password.
Map<String, String> _wrapKeyIsolate(_KeyWrapPayload payload) {
  // A unique salt is generated for each key wrapping operation.
  final salt = enc.IV.fromSecureRandom(16).bytes;

  // PBKDF2 with 100,000 rounds of HMAC-SHA256 to derive the key.
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, 100000, 32)); // 32 bytes for AES-256
  final masterKey = enc.Key(
    derivator.process(Uint8List.fromList(utf8.encode(payload.masterPassword))),
  );

  // Encrypt the data key with the derived master key.
  final encrypter = enc.Encrypter(enc.AES(masterKey)); // Defaults to CBC mode
  final iv = enc.IV.fromSecureRandom(16);
  final encryptedDataKey = encrypter.encryptBytes(payload.dataKeyBytes, iv: iv);

  // Return all components needed for decryption, encoded as Base64 strings.
  return {
    AppConstants.keySalt: base64Encode(salt),
    AppConstants.keyIv: iv.base64,
    AppConstants.keyEncryptionKey: encryptedDataKey.base64,
  };
}

/// Isolate entry point to "unwrap" (decrypt) a wrapped data key.
/// It re-derives the same master key using the
/// provided salt and master password.
Uint8List _unwrapKeyIsolate(_KeyUnwrapPayload payload) {
  final salt = base64Decode(payload.backupData[AppConstants.keySalt] as String);
  final iv = enc.IV.fromBase64(
    payload.backupData[AppConstants.keyIv] as String,
  );
  final encryptedKey = enc.Encrypted.fromBase64(
    payload.backupData[AppConstants.keyEncryptionKey] as String,
  );

  // Re-run PBKDF2 with the exact same parameters to get the same key.
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, 100000, 32));
  final masterKey = enc.Key(
    derivator.process(Uint8List.fromList(utf8.encode(payload.masterPassword))),
  );

  // Decrypt the data key.
  final encrypter = enc.Encrypter(enc.AES(masterKey));
  return Uint8List.fromList(encrypter.decryptBytes(encryptedKey, iv: iv));
}

/// A service for handling all cryptographic operations in the application.
///
/// This service implements an envelope encryption scheme:
/// 1. A strong 256-bit AES key (the Data Encryption Key or DEK) is generated
///    and stored in the device's secure storage.
/// 2. All user documents are encrypted and decrypted with this DEK.
/// 3. For cloud backup, the user's master password is used to derive a
///    Key Encryption Key (KEK) via PBKDF2.
/// 4. The KEK is then used to "wrap" (encrypt) the DEK, which can be safely
///    stored in the cloud. The KEK is never stored.
class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageIdentifier =
      AppConstants.encryptionKeyIdentifier;

  /// The single Data Encryption Key (DEK) used for all file operations.
  /// It's loaded into memory lazily.
  enc.Key? _dataKey;

  /// Initializes the service by loading or creating the data encryption key.
  /// This method is called automatically by other
  /// methods if the key isn't loaded.
  Future<void> init() async {
    if (_dataKey != null) return;
    _dataKey = await _getOrCreateKey();
  }

  /// Retrieves the DEK from secure storage,
  /// or creates and stores a new one if not found.
  Future<enc.Key> _getOrCreateKey() async {
    final base64Key = await _secureStorage.read(key: _keyStorageIdentifier);

    if (base64Key == null) {
      // Key doesn't exist, create a new 256-bit (32-byte) key.
      final newKey = enc.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: _keyStorageIdentifier,
        value: newKey.base64,
      );
      return newKey;
    } else {
      // Key exists, decode it from Base64.
      final keyBytes = base64Decode(base64Key);
      return enc.Key(keyBytes);
    }
  }

  /// Wraps the data key for cloud backup using the user's master password.
  ///
  /// Returns a map containing the encrypted key and
  /// necessary crypto parameters (salt, IV).
  Future<Map<String, String>> getEncryptedDataKeyForBackup(
    String masterPassword,
  ) async {
    if (_dataKey == null) await init();
    return compute(
      _wrapKeyIsolate,
      _KeyWrapPayload(masterPassword, _dataKey!.bytes),
    );
  }

  /// Unwraps a data key from a backup and restores it to secure storage.
  ///
  /// This replaces the current data key on the
  /// device with the one from the backup.
  Future<void> restoreDataKeyFromBackup(
    String masterPassword,
    Map<String, dynamic> backupData,
  ) async {
    final decryptedKeyBytes = await compute(
      _unwrapKeyIsolate,
      _KeyUnwrapPayload(masterPassword, backupData),
    );
    _dataKey = enc.Key(decryptedKeyBytes);
    await _secureStorage.write(
      key: _keyStorageIdentifier,
      value: _dataKey!.base64,
    );
  }

  /// Encrypts the given byte data using the app's primary data key.
  /// Runs the AES encryption in a background isolate.
  Future<Uint8List> encrypt(Uint8List data) async {
    if (_dataKey == null) await init();
    return compute(
      _encryptIsolate,
      _EncryptIsolatePayload(_dataKey!.bytes, data),
    );
  }

  /// Decrypts the given byte data using the app's primary data key.
  /// Runs the AES decryption in a background isolate.
  Future<Uint8List> decrypt(Uint8List combinedData) async {
    if (_dataKey == null) await init();
    return compute(
      _decryptIsolate,
      _DecryptIsolatePayload(_dataKey!.bytes, combinedData),
    );
  }
}
