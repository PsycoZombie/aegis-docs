import 'dart:convert';

import 'package:aegis_docs/core/services/encryption_service.dart'; // Adjust this import path to match your project structure
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // This group bundles all tests related to the EncryptionService.
  group('EncryptionService Tests', () {
    late EncryptionService encryptionService;

    // This setup code runs before each test.
    setUpAll(() async {
      // We must mock the platform-specific implementation of flutter_secure_storage
      // for tests to run in a pure Dart environment.
      FlutterSecureStorage.setMockInitialValues({});

      // Create and initialize the service.
      encryptionService = EncryptionService();
      await encryptionService.init();
    });

    test(
      'should encrypt and decrypt data successfully (round-trip test)',
      () async {
        // 1. Arrange: Define the original data we want to protect.
        const String originalString = 'This is a top secret document!';
        final Uint8List originalData = Uint8List.fromList(
          utf8.encode(originalString),
        );

        // 2. Act: Perform the encryption and decryption.
        final Uint8List encryptedBase64 = await encryptionService.encrypt(
          originalData,
        );
        final Uint8List decryptedData = await encryptionService.decrypt(
          encryptedBase64,
        );

        // 3. Assert: Check that the decrypted data is identical to the original.
        // We also check that the encrypted data is not the same as the original.
        expect(decryptedData, equals(originalData));
        expect(encryptedBase64, isNot(equals(originalString)));

        // You can also decode it back to a string to be sure.
        final String finalString = utf8.decode(decryptedData);
        expect(finalString, equals(originalString));

        debugPrint('Original data: "$originalString"');
        debugPrint('Encrypted (Base64): "$encryptedBase64"');
        debugPrint('Decrypted data: "$finalString"');
        debugPrint('✅ Round-trip test successful!');
      },
    );
  });
}
