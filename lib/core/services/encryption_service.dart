import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _keyStorageIdentifier = 'aegis_docs_encryption_key';

  enc.Encrypter? _encrypter;

  Future<void> init() async {
    if (_encrypter != null) return;

    final key = await _getOrCreateKey();
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  }

  Uint8List encrypt(Uint8List data) {
    if (_encrypter == null) {
      throw StateError(
        'EncryptionService has not been initialized. Call init() first.',
      );
    }
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encryptBytes(data, iv: iv);

    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  Uint8List decrypt(Uint8List combinedData) {
    if (_encrypter == null) {
      throw StateError(
        'EncryptionService has not been initialized. Call init() first.',
      );
    }
    if (combinedData.length < 16) {
      throw ArgumentError(
        'Invalid encrypted data: too short to contain an IV.',
      );
    }

    final ivBytes = combinedData.sublist(0, 16);
    final iv = enc.IV(ivBytes);

    final encryptedDataBytes = combinedData.sublist(16);
    final encrypted = enc.Encrypted(encryptedDataBytes);

    final decrypted = _encrypter!.decryptBytes(encrypted, iv: iv);
    return Uint8List.fromList(decrypted);
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
}
