// Import the file to be tested.
import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file.
import 'auth_service_test.mocks.dart';

// This annotation tells mockito to generate a mock class for LocalAuthentication.
@GenerateMocks([LocalAuthentication])
void main() {
  // We need a late variable because we'll initialize it in setUp.
  late MockLocalAuthentication mockLocalAuth;
  late AuthService authService;

  // setUp is called before each test runs.
  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    authService = AuthService(localAuth: mockLocalAuth);
  });

  group('AuthService', () {
    test(
      'isDeviceSupported returns true when plugin call is successful',
      () async {
        // Arrange: Tell the mock what to return when isDeviceSupported is called.
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act: Call the method we are testing.
        final result = await authService.isDeviceSupported();

        // Assert: Check if the result is what we expect.
        expect(result, isTrue);
      },
    );

    test('authenticate returns true when plugin call is successful', () async {
      // Arrange: Configure the mock to return true for a successful authentication.
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => true);

      // Act
      final result = await authService.authenticate();

      // Assert
      expect(result, isTrue);
    });

    test('authenticate returns false when plugin call is unsuccessful', () async {
      // Arrange: Configure the mock to return false for a failed authentication.
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => false);

      // Act
      final result = await authService.authenticate();

      // Assert
      expect(result, isFalse);
    });
  });
}
