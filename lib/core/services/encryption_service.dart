import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Uint8List _encryptIsolate(Map<String, dynamic> params) {
  final keyBytes = params['key'] as Uint8List;
  final data = params['data'] as Uint8List;

  final key = enc.Key(keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
  final iv = enc.IV.fromSecureRandom(16);
  final encrypted = encrypter.encryptBytes(data, iv: iv);

  return Uint8List.fromList(iv.bytes + encrypted.bytes);
}

Uint8List _decryptIsolate(Map<String, dynamic> params) {
  final keyBytes = params['key'] as Uint8List;
  final combinedData = params['data'] as Uint8List;

  final key = enc.Key(keyBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

  if (combinedData.length < 16) {
    throw ArgumentError('Invalid encrypted data: too short to contain an IV.');
  }

  final ivBytes = combinedData.sublist(0, 16);
  final iv = enc.IV(ivBytes);
  final encryptedDataBytes = combinedData.sublist(16);
  final encrypted = enc.Encrypted(encryptedDataBytes);

  final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
  return Uint8List.fromList(decrypted);
}

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _keyStorageIdentifier = 'aegis_docs_encryption_key';

  enc.Key? _key;

  Future<void> init() async {
    if (_key != null) return;
    _key = await _getOrCreateKey();
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    if (_key == null) {
      throw StateError(
        'EncryptionService has not been initialized. Call init() first.',
      );
    }
    return await compute(_encryptIsolate, {'key': _key!.bytes, 'data': data});
  }

  Future<Uint8List> decrypt(Uint8List combinedData) async {
    if (_key == null) {
      throw StateError(
        'EncryptionService has not been initialized. Call init() first.',
      );
    }
    return await compute(_decryptIsolate, {
      'key': _key!.bytes,
      'data': combinedData,
    });
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
