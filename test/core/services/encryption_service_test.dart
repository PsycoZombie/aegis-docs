import 'dart:convert';
import 'dart:typed_data';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// This annotation tells the build_runner to generate
// a mock class for FlutterSecureStorage.
@GenerateMocks([FlutterSecureStorage])
import 'encryption_service_test.mocks.dart';

void main() {
  // We declare the variables that will be used across multiple tests.
  late EncryptionService encryptionService;
  late MockFlutterSecureStorage mockSecureStorage;

  // The setUp function is called before each individual test runs.
  // This ensures that each test starts with a
  // fresh, clean instance of our service.
  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    // We inject the mock dependency into our service.
    // Note: We need to modify the EncryptionService to allow this injection.
    encryptionService = EncryptionService(secureStorage: mockSecureStorage);
  });

  // A group is a way to organize related tests.
  group('Encryption Key Management', () {
    test(
      'should create and save a new key when no key exists in secure storage',
      () async {
        // Arrange: Set up the conditions for the test.
        // We tell the mock to return null when 'read' is called,
        // simulating an empty storage.
        when(
          mockSecureStorage.read(key: AppConstants.encryptionKeyIdentifier),
        ).thenAnswer((_) async => null);
        // We also set up the mock for the 'write' call
        // that we expect to happen.
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        // Act: Call the method we want to test.
        await encryptionService.init();

        // Assert: Verify that the expected outcomes occurred.
        // We verify that the 'write' method was called
        // exactly once with the correct key.
        verify(
          mockSecureStorage.write(
            key: AppConstants.encryptionKeyIdentifier,
            value: anyNamed('value'),
          ),
        ).called(1);
      },
    );

    test('should load an existing key from secure storage', () async {
      // Arrange: Set up a fake key to be "loaded".
      final fakeKey = base64Encode(Uint8List(32));
      when(
        mockSecureStorage.read(key: AppConstants.encryptionKeyIdentifier),
      ).thenAnswer((_) async => fakeKey);

      // Act
      await encryptionService.init();

      // Assert: Verify that the 'write' method was
      // NEVER called, because the key already existed.
      verifyNever(
        mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });
  });

  group('Data Encryption and Decryption', () {
    test('should correctly encrypt and then decrypt data', () async {
      // Arrange
      final testData = Uint8List.fromList('Hello, Aegis Docs!'.codeUnits);
      final fakeKey = base64Encode(Uint8List(32));
      when(
        mockSecureStorage.read(key: AppConstants.encryptionKeyIdentifier),
      ).thenAnswer((_) async => fakeKey);

      // Act
      final encryptedData = await encryptionService.encrypt(testData);
      final decryptedData = await encryptionService.decrypt(encryptedData);

      // Assert: The decrypted data should be identical to the original data.
      expect(decryptedData, equals(testData));
      // Also, the encrypted data should NOT be the same as the original.
      expect(encryptedData, isNot(equals(testData)));
    });
  });

  group('Key Wrapping and Unwrapping for Backup', () {
    test('should wrap and then unwrap the data key successfully', () async {
      // Arrange
      const masterPassword = 'secure_password_123';
      final fakeKey = base64Encode(Uint8List(32));
      when(
        mockSecureStorage.read(key: AppConstants.encryptionKeyIdentifier),
      ).thenAnswer((_) async => fakeKey);
      when(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {
        return;
      });

      // Act
      final wrappedKeyData = await encryptionService
          .getEncryptedDataKeyForBackup(masterPassword);
      await encryptionService.restoreDataKeyFromBackup(
        masterPassword,
        wrappedKeyData,
      );

      // Assert
      // We verify that the 'write' method was called,
      // which means a key was successfully
      // unwrapped and is being saved back to storage.
      verify(
        mockSecureStorage.write(
          key: AppConstants.encryptionKeyIdentifier,
          value: anyNamed('value'),
        ),
      ).called(1);
    });

    test(
      'should fail to unwrap the data key with an incorrect password',
      () async {
        // Arrange
        const correctPassword = 'secure_password_123';
        const wrongPassword = 'wrong_password';
        final fakeKey = base64Encode(Uint8List(32));
        when(
          mockSecureStorage.read(key: AppConstants.encryptionKeyIdentifier),
        ).thenAnswer((_) async => fakeKey);

        // Act
        final wrappedKeyData = await encryptionService
            .getEncryptedDataKeyForBackup(correctPassword);

        // Assert: We expect that calling
        // restoreDataKeyFromBackup with the wrong
        // password will throw an exception.
        expect(
          () => encryptionService.restoreDataKeyFromBackup(
            wrongPassword,
            wrappedKeyData,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
