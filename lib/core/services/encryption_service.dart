import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class _EncryptIsolatePayload {
  final Uint8List keyBytes;
  final Uint8List data;
  _EncryptIsolatePayload(this.keyBytes, this.data);
}

class _DecryptIsolatePayload {
  final Uint8List keyBytes;
  final Uint8List data;
  _DecryptIsolatePayload(this.keyBytes, this.data);
}

class _KeyWrapPayload {
  final String masterPassword;
  final Uint8List dataKeyBytes;
  _KeyWrapPayload(this.masterPassword, this.dataKeyBytes);
}

class _KeyUnwrapPayload {
  final String masterPassword;
  final Map<String, dynamic> backupData;
  _KeyUnwrapPayload(this.masterPassword, this.backupData);
}

Uint8List _encryptIsolate(_EncryptIsolatePayload params) {
  final key = enc.Key(params.keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  final iv = enc.IV.fromSecureRandom(16);
  final encrypted = encrypter.encryptBytes(params.data, iv: iv);
  return Uint8List.fromList(iv.bytes + encrypted.bytes);
}

Uint8List _decryptIsolate(_DecryptIsolatePayload params) {
  final key = enc.Key(params.keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  if (params.data.length < 16) {
    throw ArgumentError('Invalid encrypted data: too short to contain an IV.');
  }
  final iv = enc.IV(params.data.sublist(0, 16));
  final encrypted = enc.Encrypted(params.data.sublist(16));
  return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
}

// THE FIX: This heavy cryptographic work now runs in an isolate.
Map<String, String> _wrapKeyIsolate(_KeyWrapPayload payload) {
  final salt = enc.IV.fromSecureRandom(16).bytes;

  // 1. Derive master key from password (slow part)
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, 100000, 32));
  final masterKey = enc.Key(
    derivator.process(Uint8List.fromList(utf8.encode(payload.masterPassword))),
  );

  // 2. Encrypt the data key
  final encrypter = enc.Encrypter(enc.AES(masterKey));
  final iv = enc.IV.fromSecureRandom(16);
  final encryptedDataKey = encrypter.encryptBytes(payload.dataKeyBytes, iv: iv);

  return {
    'salt': base64Encode(salt),
    'iv': iv.base64,
    'key': encryptedDataKey.base64,
  };
}

// THE FIX: This also runs in an isolate.
Uint8List _unwrapKeyIsolate(_KeyUnwrapPayload payload) {
  final salt = base64Decode(payload.backupData['salt'] as String);
  final iv = enc.IV.fromBase64(payload.backupData['iv'] as String);
  final encryptedKey = enc.Encrypted.fromBase64(
    payload.backupData['key'] as String,
  );

  // 1. Derive master key from password (slow part)
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, 100000, 32));
  final masterKey = enc.Key(
    derivator.process(Uint8List.fromList(utf8.encode(payload.masterPassword))),
  );

  // 2. Decrypt the data key
  final encrypter = enc.Encrypter(enc.AES(masterKey));
  return Uint8List.fromList(encrypter.decryptBytes(encryptedKey, iv: iv));
}

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _keyStorageIdentifier = 'aegis_docs_encryption_key';
  // static const _saltStorageIdentifier = 'aegis_docs_salt';

  enc.Key? _dataKey;

  Future<void> init() async {
    if (_dataKey != null) return;
    _dataKey = await _getOrCreateKey();
  }

  Future<enc.Key> _getOrCreateKey() async {
    String? base64Key = await _secureStorage.read(key: _keyStorageIdentifier);

    if (base64Key == null) {
      final newKey = enc.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: _keyStorageIdentifier,
        value: newKey.base64,
      );
      return newKey;
    } else {
      final keyBytes = base64Decode(base64Key);
      return enc.Key(keyBytes);
    }
  }

  // enc.Key _deriveKeyFromPassword(String password, Uint8List salt) {
  //   final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
  //     ..init(Pbkdf2Parameters(salt, 100000, 32)); // 100,000 iterations
  //   return enc.Key(
  //     derivator.process(Uint8List.fromList(utf8.encode(password))),
  //   );
  // }

  /// Encrypts the main data key using a key derived from the master password.
  Future<Map<String, String>> getEncryptedDataKeyForBackup(
    String masterPassword,
  ) async {
    if (_dataKey == null) await init();
    return await compute(
      _wrapKeyIsolate,
      _KeyWrapPayload(masterPassword, _dataKey!.bytes),
    );
  }

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

  // --- Standard Encryption/Decryption ---

  Future<Uint8List> encrypt(Uint8List data) async {
    if (_dataKey == null) await init();
    return await compute(
      _encryptIsolate,
      _EncryptIsolatePayload(_dataKey!.bytes, data),
    );
  }

  Future<Uint8List> decrypt(Uint8List combinedData) async {
    if (_dataKey == null) await init();
    return await compute(
      _decryptIsolate,
      _DecryptIsolatePayload(_dataKey!.bytes, combinedData),
    );
  }

  // Future<enc.Key> _getOrCreateDataKey() async {
  //   String? base64Key = await _secureStorage.read(key: _keyStorageIdentifier);
  //   if (base64Key == null) {
  //     final newKey = enc.Key.fromSecureRandom(32);
  //     await _secureStorage.write(
  //       key: _keyStorageIdentifier,
  //       value: newKey.base64,
  //     );
  //     return newKey;
  //   } else {
  //     return enc.Key(base64Decode(base64Key));
  //   }
  // }
}
