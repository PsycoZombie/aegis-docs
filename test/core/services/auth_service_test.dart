import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

// This annotation tells build_runner to
// generate a mock for LocalAuthentication.
@GenerateMocks([LocalAuthentication])
void main() {
  late AuthService authService;
  late MockLocalAuthentication mockLocalAuth;

  // This runs before each test, ensuring a clean state.
  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    // We inject our mock dependency into the service.
    authService = AuthService(localAuth: mockLocalAuth);
  });

  group('AuthService', () {
    test(
      'isDeviceSupported should call the corresponding '
      'method on LocalAuthentication',
      () async {
        // Arrange: When isDeviceSupported is called on the mock, return true.
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act: Call the method we are testing.
        final result = await authService.isDeviceSupported();

        // Assert: Verify that the method on the mock was called exactly once,
        // and that our service returned the correct value.
        verify(mockLocalAuth.isDeviceSupported()).called(1);
        expect(result, isTrue);
      },
    );

    test(
      'authenticate should return true on successful authentication',
      () async {
        // Arrange: When authenticate is called, simulate a successful result.
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        final result = await authService.authenticate();

        // Assert
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            options: anyNamed('options'),
          ),
        ).called(1);
        expect(result, isTrue);
      },
    );

    test(
      'authenticate should return false when a PlatformException is thrown',
      () async {
        // Arrange: When authenticate is called, simulate a PlatformException.
        // This happens when the user cancels the auth prompt.
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            options: anyNamed('options'),
          ),
        ).thenThrow(PlatformException(code: 'auth_error'));

        // Act
        final result = await authService.authenticate();

        // Assert
        expect(result, isFalse);
      },
    );
  });
}
